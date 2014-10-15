class User < ActiveRecord::Base
  #Version 0.7 (Alpha) --users will have role "Alpha"

  belongs_to :location
  has_many   :friend_relationships, class_name: "Relationship", foreign_key: 'user_id' #fk = reference to person who is doing the looking for things
  has_many   :friends,              through:    :friend_relationships #things looking for. Source is name of the "things" if differs from name in join table
  has_many   :invitations
  has_many   :received_messages, -> { order( "created_at DESC" ) }, class_name: 'Message', foreign_key: 'recipient_id'
  has_many   :sent_messages,     -> { order( "created_at DESC" ) }, class_name: 'Message', foreign_key: 'sender_id'
  has_many   :tokens
  has_many   :unlistings
  has_many   :unimages
  has_one    :questionaire
  has_one    :preference

  # External Forces
  has_secure_password
  mount_uploader    :avatar, AvatarUploader
  self.per_page  =  20

  # Callbacks
  before_validation :generate_and_check_username,                on: :create
  before_validation :set_user_location_to_default,               on: :create
  before_validation :set_initial_invitations_to_settings_ration, on: :create
  before_create     :set_initial_values
  before_create     :make_alpha_questionaire  #THIS WILL EVENTUALLY BE REMOVED
  before_save       :toggle_avatar_use_with_changes
  after_create      :make_user_preferences
  after_create      :set_welcome_examples


  # Validations
  validate  :agrees_to_terms_and_conditions, on: :create
  validates :email,    email:    true
  validates :email,    presence: true, uniqueness: { case_sensitive: false }
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password, length: { minimum: 6 }, :if => :password




  ############################## CUSTOM CALLBACKS ##############################
  def set_initial_values
    self.role            = "alpha" #WILL CHANGE TO BETA
    self.status          = "Unconfirmed"
    set_initial_prt_created_at
  end

  def generate_and_check_username #User slugs itself due to complexities otherwise
    name = generate_username
    for name in User.all.map(&:username)
      name = generate_username
    end
    self.username = name
    self.slug     = name
  end

  #ALPHA ONLY - REMOVED LATER
  def make_alpha_questionaire #WILL CHANGE TO BETA
    self.create_questionaire
  end

  def set_initial_invitations_to_settings_ration
    initial_value     = Setting.first.invites_ration
    self.invite_count = initial_value
  end

  def set_initial_prt_created_at
    self.prt_created_at = 1.month.ago #for security
  end

  def make_user_preferences
    self.create_preference
  end

  def set_welcome_examples
    set_admin_friend_example
    create_welcome_message
    create_example_unlisting
  end

  def set_user_location_to_default
    #AWFUL LOC. TESTS SHOULD NOT AFFECT CODE, BUT CUMBERSOME TO WORK AROUND THIS.
    !Rails.env.test? ? (self.location = Location.find(2)) : (self.location = Location.first)
  end

  def toggle_avatar_use_with_changes
    if self.avatar_changed? && (self.avatar_change[1].present?)
      self.update_columns(use_avatar: true)
    elsif self.avatar_changed? && (self.avatar_change[1].blank?)
      self.update_columns(use_avatar: false)
    end
  end


  ############################# CUSTOM VALIDATIONS #############################
  def agrees_to_terms_and_conditions
    errors.add(:termsconditions, "You must agree to the terms and conditions.") unless self.termsconditions.present?
  end


  ############################### PUBLIC METHODS ###############################
  #Token Methods
  def create_reset_token
    self.update_columns(prt: User.secure_token, prt_created_at: Time.now)
  end
  def clear_reset_token
    self.update_columns(prt: nil, prt_created_at: 1.month.ago)
  end
  def expired_token?(timeframe)
    self.prt_created_at.blank? ? true : self.prt_created_at < timeframe.hours.ago
  end

  #Generate Methods
  #Generate unlister with 9-Digit number (eg: unlister123456789)
  def generate_username
    digits = SecureRandom.random_number(1000000000000).to_s.ljust(12,"0")
    fullname = "unlister" + digits
  end
  def self.secure_token
    SecureRandom.urlsafe_base64
  end

  #New User Welcome & Examples (would like to put methods in their respective classes)
  def set_admin_friend_example
    self.friends << User.first
  end
  def create_welcome_message
    Message.create(recipient: self,
                     subject: "Welcome to Unlist.it!",
                     content: "We suggest you start by adding as many unlistings (wishlist items) as you can think of - this makes up your unlist (wishlist). Then search & add any friends/family - this makes it convenient to view their unlists (wishlists). If they're not on Unlist.it yet, invite them! Add more unlistings anytime you'd like. Enjoy!",
               contact_email: nil,
                   sender_id: 1,
            messageable_type: "User",
              messageable_id: 1,
                    msg_type: "Admin",
                  deleted_at: nil)
  end
  def create_example_unlisting
    Unlisting.create(     creator: self,
                      category_id: 1,
                     condition_id: 166,
                            title: "Money(USD)",
                      description: "Looking for money. Any amount. Prefer larger bills. No torn bills. No fake bills. USD only. (See the FAQ for more info on Community Reuse)",
                         keyword1: "money",
                         keyword2: "benjamins",
                             link: "http://en.wikipedia.org/wiki/United_States_dollar",
                            price: 0,
                       link_image: "http://upload.wikimedia.org/wikipedia/commons/thumb/6/64/USDnotes.png/252px-USDnotes.png")
  end


  # Checks
  def admin?
    role == "admin"
  end
  def can_befriend?(user)
    true unless (user == self) || self.friends.include?(user)
  end
  def invitations_avail?
    self.invite_count.nil? ? false : (self.invite_count > 0)
  end

  #Query Methods
  def all_msgs_sent_received
    Message.where([ "sender_id = :sender OR recipient_id = :recipient", { sender: self.id, recipient: self.id } ]).active.where.not("messageable_type = 'Message'").order('created_at DESC')
    # self.received_messages.push(self.sent_messages).flatten.uniq.sort.reverse.select{|m| ((m.messageable_type != "Message") && (m.deleted_at == nil))} #NOT replies
  end

  def count_found
    self.unlistings.found.size
  end

  #Setting & Resetting Values
  def set_confirmed
    self.update_columns(confirmed: true, status: "OK")
  end
  def use_default_avatar
    self.update_column(:use_avatar, false)
  end
  def decorator
    UserDecorator.new(self)
  end
  def to_param #make program use slug instead of id in params
    self.slug
  end

  def set_termsconditions
    self.termsconditions = Time.now
  end
end
