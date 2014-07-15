class Unpost < ActiveRecord::Base

  belongs_to  :creator, foreign_key: 'user_id', class_name: "User"
  belongs_to  :category
  belongs_to  :condition
  has_many    :messages, as: :messageable
  has_many    :unimages
  accepts_nested_attributes_for :unimages, allow_destroy: true


  # Scopes to filter query results
  scope      :active,      -> { where inactive: [false, nil]  }
  scope      :inactive,    -> { where inactive: true  }
  scope      :hits,        -> { where "id IN (SELECT messageable_id FROM Messages where messageable_type='Unpost')" }


  # Validations
  #before_validation :filter_dollar_symbols_from_price
  validates_associated  :unimages  #ensure don't exceed unimage limit
  validates_presence_of :title, :description, :keyword1,
                        :condition_id, :category_id, :user_id#, :travel
  validates :keyword2, presence: true, allow_blank: true
  validates :keyword3, presence: true, allow_blank: true
  validates :keyword4, presence: true, allow_blank: true
  validates :link,     presence: true, allow_blank: true
  validates :price,    numericality: { only_integer: true}


  # private
  # def filter_dollar_symbols_from_price
  #   binding.pry
  #   price_string = self.price.to_s
  #   price_string.gsub!(/[$]/, "")
  #   binding.pry
  #   price_string.to_i ? (self.price = price_string.to_i) : errors.add(:price, "Numbers ONLY for price. Example: $0.99 => 1, $2,000 => 2000, etc...")
  # end
end
