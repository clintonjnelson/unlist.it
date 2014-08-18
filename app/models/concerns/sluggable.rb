module Sluggable
  extend ActiveSupport::Concern

  # Class methods to be called by the Class including this Module
  included do
    class_attribute   :slug_column  # Variable for setting thru setter in Model (ie: choose sluggable column)
    class_attribute   :slug_leader
    class_attribute   :slug_length
    class_attribute   :slug_type
    before_validation :set_slug, on: :create
  end


  def to_param #make program use slug instead of id in params.
    self.slug
  end

  def set_slug #makes slug from sluggable & adds a count to end if used prior
    case self.slug_type
      when :column
        slug_base  = generate_slug_from_slug_column
        slug_final = verify_unique_or_increment_slug(slug_base)
        self.slug = slug_final
      when :number
        slug = generate_leader_number_slug_of_length(slug_length)
        while !unique?(slug) #refactor to one=line
          slug = generate_leader_number_slug_of_length(slug_length)
        end
        self.slug = slug
    end
  end

  #private
  def generate_slug_from_slug_column
    unless self.send(self.class.slug_column.to_sym).blank?
      self.send(self.class.slug_column.to_sym).scan(/[a-zA-Z0-9]+/).join("-").downcase
    end
  end

  def generate_random_number_of_length(length)
    SecureRandom.random_number(("1"+"#{'0'*length}").to_i).to_s.ljust(length,"0")
  end

  def generate_leader_number_slug_of_length(length)
    slug_leader + generate_random_number_of_length(length)
  end

  def verify_unique_or_increment_slug(slug_base)
    if slug_base.blank?
      errors.add(:base, 'Could Not Process Due To A Missing Value')
      return false
    end
    slugtest = slug_base
    count    = 2   #2nd copy requires increment at 2
    while self.class.find_by(slug: slugtest) && (self.class.find_by(slug: slugtest) != self)
      slugtest  = slug_base + "-#{count}"
      count    += 1
    end
    slugtest
  end

  def unique?(slug)
    self.class.all.map(&:slug).include?(slug) ? false : true
  end



  module ClassMethods

    def sluggable_type(type, length=12, leader="")
      self.slug_type   = type
      self.slug_length = length
      self.slug_leader = leader
    end

    def sluggable_column(column)
      self.slug_column = column
    end

    def sluggable_callback(callback_time)
      self.slug_callback = callback_time
    end
  end
end
