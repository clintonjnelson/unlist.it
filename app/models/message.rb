class Message < ActiveRecord::Base
  belongs_to :messageable, polymorphic: true
  belongs_to :recipient, foreign_key: 'recipient_id', class_name: 'User'
  belongs_to :sender,    foreign_key: 'sender_id', class_name: 'User' #sender is nil for guests

  validates :messageable_type,  presence: true
  validates :messageable_id,    presence: true
  validates :recipient_id,      presence: true
  validates :subject,           presence: true
  validates :content,           presence: true, allow_blank: true
  validates_presence_of :sender_id,     unless: 'self.contact_email.present?'
  validates_presence_of :contact_email, unless: 'self.sender_id.present?'
end
