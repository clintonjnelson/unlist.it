class Unpost < ActiveRecord::Base

  belongs_to  :creator, foreign_key: 'user_id', class_name: "User"
  belongs_to  :category
  belongs_to  :condition
  has_many    :unimages
  accepts_nested_attributes_for :unimages, allow_destroy: true


  validates_associated  :unimages  #ensure don't exceed unimage limit
  validates_presence_of :title, :description, :keyword1,
                        :condition_id, :category_id, :user_id#, :travel
  # Validates but allows blank
  validates :keyword2, presence: true, allow_blank: true
  validates :keyword3, presence: true, allow_blank: true
  validates :keyword4, presence: true, allow_blank: true
  validates :link,     presence: true, allow_blank: true
  validates :price,    numericality: { only_integer: true}
  # validates :distance, numericality: { only_integer: true}, allow_blank: true
  # validates :zipcode,  numericality: { only_integer: true}, length: {is: 5}
end
