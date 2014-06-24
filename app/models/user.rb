class User < ActiveRecord::Base
  has_many   :received_messages, ->{ order( "created_at DESC" ) }, class_name: 'Message', foreign_key: 'recipient_id'
  has_many   :sent_messages, ->{ order( "created_at DESC" ) },     class_name: 'Message', foreign_key: 'sender_id'
  has_many   :tokens
  has_many   :unposts

  has_secure_password
  before_create :set_initial_prt_created_at

  validates :email,    email: true
  validates :email,    presence: true, uniqueness: { case_sensitive: false }
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password, length: { minimum: 6 }, :if => :password

  mount_uploader :avatar, AvatarUploader



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

  def expired_token?(timeframe)
    self.prt_created_at.blank? ? true : self.prt_created_at < timeframe.hours.ago
  end

  def self.secure_token
    SecureRandom.urlsafe_base64
  end

  def set_initial_prt_created_at
    self.prt_created_at = 1.month.ago #for security
  end
end
