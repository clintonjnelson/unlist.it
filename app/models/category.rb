class Category < ActiveRecord::Base
  has_many :unposts, ->{ order( "created_at ASC" ) } #governs return order. Consider Removing for Flexibility.
  has_many :conditions, ->{ order( "position" ) }, dependent: :destroy

  validates :name, presence: true

  def reorder_conditions
    conditions.each_with_index do |condition, index|
      condition.update_column(:position, (index+1))
    end
  end
end
