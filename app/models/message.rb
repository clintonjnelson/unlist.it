class Message < ActiveRecord::Base
  include Sluggable
    sluggable_type :number, 15 #Use a 15-digit random number

  belongs_to :messageable, polymorphic: true #unlisting & user
  belongs_to :recipient,   foreign_key: 'recipient_id', class_name: 'User'
  belongs_to :sender,      foreign_key: 'sender_id', class_name: 'User' #sender is nil for guests
  has_many   :messages,    as: :messageable #replies

  # Scope Filters
  scope   :active,          -> { where deleted_at:        nil      }
  scope   :initialresponse, -> { where messageable_type: 'Unlisting'  }
  scope   :reply_filter,    -> { where messageable_type: 'Message' }

  # Validations
  validates :messageable_type,  presence: true
  validates :messageable_id,    presence: true
  validates :recipient_id,      presence: true
  validates :subject,           presence: true
  validates :content,           presence: true
  validates :contact_email, email: true, unless: 'self.sender_id.present?'
  validates_presence_of :sender_id,      unless: 'self.contact_email.present?'


  # External Forces
  self.per_page = 20



  def replies
    self.messages.active.reply_filter.order('created_at DESC')
  end

  def delete_subcorrespondence
    self.messages.each do |reply|
      reply.update_column(:deleted_at, Time.now)
    end if self.messages.present? #double-check this is supposed to be .present? & not .blank?
  end

  #Probably need to make a message inactive when:
    #Unlisting parent is made inactive, make all of its messages inactive too
    #User specifically "deletes" the message
    #A User is suspended - ALL messages by user are "suspended" (NOT deleted, as bring them back if un-suspend)


  #Looks like need columns like:
    #Messages.status (:string, status can be: "suspended", "inappropriate", "spam", "etc")
      #This seems like would utilize a MessagesPolicy? UserPolicy would get involves with suspensions & such.
end
