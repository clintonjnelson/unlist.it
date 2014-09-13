class Category < ActiveRecord::Base
  include Sluggable #Uses title for slug instead of :id
    sluggable_type   :column
    sluggable_column :name

  has_many :unlistings, ->{ order( "created_at ASC" ) } #governs return order. Consider Removing for Flexibility.
  has_many :conditions, ->{ order( "position" ) }, dependent: :destroy


  # Callbacks
  before_save   :downcase_name
  before_save   :set_slug

  # Validations
  validates :name, presence: true

  def reorder_conditions
    conditions.each_with_index do |condition, index|
      condition.update_column(:position, (index+1))
    end
  end

  # Callback Methods
  def downcase_name
    self.name = self.name.downcase
  end
  ###DELETE THIS AFTER RUN ONCE - REDUNDANT TO THE SLUGGABLE GEM
  def set_slug
    self.slug = self.name.scan(/[a-zA-Z0-9]+/).join("-").downcase
  end
end
