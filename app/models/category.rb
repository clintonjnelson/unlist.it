class Category < ActiveRecord::Base
  has_many :categories_conditions
  has_many :conditions, through: :categories_conditions
end
