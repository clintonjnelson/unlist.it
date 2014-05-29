class CategoriesCondition < ActiveRecord::Base
  belongs_to :category    #foreign_key: category_id
  belongs_to :condition   #foreign_key: condition_id
end
