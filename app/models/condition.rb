class Condition < ActiveRecord::Base
  has_many :categories_conditions
  has_many :categories, through: :categories_conditions
end
