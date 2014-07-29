class User < ActiveRecord::Base
  has_many   :received_messages, -> { (order "created_at DESC") }, class_name: 'Message', foreign_key: 'recipient_id'
  has_many   :sent_messages, ->{ order( "created_at DESC" ) },     class_name: 'Message', foreign_key: 'sender_id'
  has_many   :tokens
  has_many   :unposts
  has_many   :unimages

  # External Forces
  has_secure_password
  mount_uploader :avatar, AvatarUploader

  # Callbacks
  before_create :set_initial_prt_created_at
  before_save   :toggle_avatar_use_with_changes

  # Validations
  validates :email,    email: true
  validates :email,    presence: true, uniqueness: { case_sensitive: false }
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password, length: { minimum: 6 }, :if => :password




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

  def expired_token?(timeframe)
    self.prt_created_at.blank? ? true : self.prt_created_at < timeframe.hours.ago
  end

  def self.secure_token
    SecureRandom.urlsafe_base64
  end

  def all_msgs_sent_received
    messages_array = self.received_messages
    messages_array << self.sent_messages
    messages_array.select{|m| ((m.messageable_type != "Message") && (m.deleted_at == nil))} #NOT replies
  end

  def set_initial_prt_created_at
    self.prt_created_at = 1.month.ago #for security
  end

  def use_default_avatar
    self.update_column(:use_avatar, false)
  end

  def toggle_avatar_use_with_changes
    if self.avatar_changed? && (self.avatar_change[1].present?)
      self.update_columns(use_avatar: true)
    elsif self.avatar_changed? && (self.avatar_change[1].blank?)
      self.update_columns(use_avatar: false)
    end
  end
end
