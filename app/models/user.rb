class User < ActiveRecord::Base

  belongs_to :location
  has_many   :invitations
  has_many   :received_messages, -> { (order "created_at DESC") }, class_name: 'Message', foreign_key: 'recipient_id'
  has_many   :sent_messages, ->{ order( "created_at DESC" ) },     class_name: 'Message', foreign_key: 'sender_id'
  has_many   :tokens
  has_many   :unposts
  has_many   :unimages

  # External Forces
  has_secure_password
  mount_uploader :avatar, AvatarUploader

  # Callbacks
  before_create     :set_initial_prt_created_at
  before_validation :generate_and_check_username, on: :create
  before_save       :toggle_avatar_use_with_changes

  # Validations
  validates :email,    email:    true
  validates :email,    presence: true, uniqueness: { case_sensitive: false }
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password, length: { minimum: 6 }, :if => :password




  ############################## CUSTOM CALLBACKS ##############################
  def generate_and_check_username
    name = generate_username
    #usernames = User.all.map(&:username)
    for name in User.all.map(&:username)
      name = generate_username
    end
    self.username = name
    self.slug     = name
  end

  def set_initial_prt_created_at
    self.prt_created_at = 1.month.ago #for security
  end

  def toggle_avatar_use_with_changes
    if self.avatar_changed? && (self.avatar_change[1].present?)
      self.update_columns(use_avatar: true)
    elsif self.avatar_changed? && (self.avatar_change[1].blank?)
      self.update_columns(use_avatar: false)
    end
  end

  ############################### PUBLIC METHODS ###############################
  def admin?
    role == "admin"
  end

  def create_reset_token
    self.update_columns(prt: User.secure_token, prt_created_at: Time.now)
  end

  def clear_reset_token
    self.update_columns(prt: nil, prt_created_at: 1.month.ago)
  end

  def decorator
    UserDecorator.new(self)
  end

  #Generate unlister with 9-Digit number (eg: unlister123456789)
  def generate_username
    digits = SecureRandom.random_number(1000000000000).to_s.ljust(12,"0")
    fullname = "unlister" + digits
  end

  def expired_token?(timeframe)
    self.prt_created_at.blank? ? true : self.prt_created_at < timeframe.hours.ago
  end

  def self.secure_token
    SecureRandom.urlsafe_base64
  end

  def all_msgs_sent_received
    messages_array = []
    messages_array << self.received_messages
    messages_array << self.sent_messages
    messages_array.flatten.sort.reverse.select{|m| ((m.messageable_type != "Message") && (m.deleted_at == nil))} #NOT replies
  end

  # Maybe move this to UserPolicy... or InvitationPolicy?
  def invitations_avail?
    self.invite_count > 0
  end

  def to_param #make program use slug instead of id in params
    self.slug
  end

  def use_default_avatar
    self.update_column(:use_avatar, false)
  end
end
