class Unlisting < ActiveRecord::Base
  include Sluggable #Uses title for slug instead of :id
    sluggable_type   :column
    sluggable_column :title

  belongs_to  :creator,  foreign_key: 'user_id', class_name: "User"
  belongs_to  :category
  belongs_to  :condition
  has_many    :messages, as: :messageable
  has_many    :unimages
  #accepts_nested_attributes_for :unimages, allow_destroy: true

  # Callbacks


  # Scopes to filter query results
  scope       :active,       -> { where   inactive: [nil, false     ] }
  scope       :inactive,     -> { where   inactive: true              }
  scope       :for_everyone, -> { where visibility: [nil, "everyone"] }
  scope       :found,        -> { where      found: true              }
  scope       :hits,         -> { where "id IN (SELECT messageable_id FROM Messages where messageable_type='Unlisting')" }



  # Validations
  validates_presence_of  :title, :keyword1, :condition_id, :category_id, :user_id
  validates   :keyword2, presence: true, allow_blank: true
  validates   :keyword3, presence: true, allow_blank: true
  validates   :keyword4, presence: true, allow_blank: true
  validates   :link,     presence: true,
                              url: true, allow_blank: true
  validates   :price,    numericality: { only_integer: true }

  #Exernal Forces
  self.per_page = 20


  def parent_messages
    self.messages.active.initialresponse.order('created_at DESC')
  end

  # Soft-Delete replies then parents from Unlisting
  def soft_delete
    self.update_columns(inactive: true, found: false, updated_at: Time.now)
    delete_correspondence
  end

  def set_found
    self.update_columns(found: true)
  end

  def delete_correspondence
    self.messages.each do |parent|
      parent.messages.each do |reply|
        reply.update_column(:deleted_at, Time.now)
      end if parent.messages.present?
      parent.update_column( :deleted_at, Time.now)
    end if self.messages.present?
  end

end
