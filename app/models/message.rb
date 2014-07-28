class Message < ActiveRecord::Base
  belongs_to :messageable, polymorphic: true #unpost & user
  belongs_to :recipient,   foreign_key: 'recipient_id', class_name: 'User'
  belongs_to :sender,      foreign_key: 'sender_id', class_name: 'User' #sender is nil for guests
  has_many   :messages,    as: :messageable #replies

  # Scope Filters
  scope   :initialresponse, -> { where messageable_type: 'Unpost'  }
  scope   :reply_filter,    -> { where messageable_type: 'Message' }

  validates :messageable_type,  presence: true
  validates :messageable_id,    presence: true
  validates :recipient_id,      presence: true
  validates :subject,           presence: true
  validates :content,           presence: true
  validates_presence_of :sender_id,     unless: 'self.contact_email.present?'
  validates_presence_of :contact_email, unless: 'self.sender_id.present?'

  def replies
    self.messages.reply_filter.order('created_at DESC')
  end

  #Probably need to make a message inactive when:
    #Unpost parent is made inactive, make all of its messages inactive too
    #User specifically "deletes" the message
    #A User is suspended - ALL messages by user are "suspended" (NOT deleted, as bring them back if un-suspend)


  #Looks like need columns like:
    #NOW:   Messages.inactive (:boolean)
    #LATER: Messages.status (:string, status can be: "suspended", "inappropriate", "spam", "etc")
      #This seems like would utilize a MessagesPolicy? UserPolicy would get involves with suspensions & such.
end
