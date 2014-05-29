class Unpost < ActiveRecord::Base

belongs_to  :user
belongs_to  :category
belongs_to  :condition

validates_presence_of :title, :description, :keyword1, :travel,
                      :condition_id, :category_id, :user_id

# Validates & allows blank
validates :keyword2, presence: true, allow_blank: true
validates :keyword3, presence: true, allow_blank: true
validates :keyword4, presence: true, allow_blank: true
validates :link,     presence: true, allow_blank: true

validates :price,    numericality: { only_integer: true}
validates :distance, numericality: { only_integer: true}, allow_blank: true
validates :zipcode,  numericality: { only_integer: true}, length: {is: 5}
end
