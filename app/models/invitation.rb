class Invitation < ActiveRecord::Base
  belongs_to :sender, foreign_key: 'user_id', class_name: "User"

  before_save :generate_token
  validates   :recipient_email,    email: true #email_validator gem
  validates   :recipient_email, presence: true
  validates   :user_id,         presence: true


  def set_redeemed
    sender_notification(self.sender)
    self.update_column(:token, nil)
    ## Could make a new message in here notifying sender that recipient signed up
    ## Could send a first-message to the recipient welcoming them
  end



  private
  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end

  # Sends a notice to inviter of the new user
  def sender_notification(inviter)
    title   = "#{self.recipient_email} Has Joined Unlist"
    message = "Your invitation to #{self.recipient_email} has been accepted! Thanks for helping us grow - one quality person at a time."
    admin   = User.find_by(role: "admin") || User.find_by(role: "Admin")

    if admin
      message = Message.create(sender_id: 1,
                            recipient: inviter,
                        contact_email: nil,
                              subject: title,
                              content: message,
                     messageable_type: "User",
                       messageable_id: 1 )
    end
  end
end
