class User < ActiveRecord::Base
  #Needed to separate messages between received/sent
  has_many   :received_messages, class_name: 'Message', foreign_key: 'recipient_id'
  has_many   :sent_messages,     class_name: 'Message', foreign_key: 'sender_id'
  has_many   :tokens
  has_many   :unposts
  has_secure_password


  validates :email,    email: true
  validates :email,    presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  def admin?
    role == "admin"
  end
end
