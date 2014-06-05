class Condition < ActiveRecord::Base
  #has_many :categories_conditions
  #has_many :categories, through: :categories_conditions
  belongs_to :category

  validates :level,     presence:     true,
                        uniqueness:   { scope: :category_id }
  validates :position,  numericality: { only_integer: true },
                        allow_blank:  true,
                        uniqueness:   { scope: :category_id }

  def other_conditions_for_category
    category.conditions.where.not(id: id)
  end
end
