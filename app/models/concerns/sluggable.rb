module Sluggable
  extend ActiveSupport::Concern

  # Class methods to be called by the Class including this Module
  included do
    before_save     :set_slug     # Callback needed to Parse & form valid slug string
    class_attribute :slug_column  # Variable for setting thru setter in Model (ie: choose sluggable column)
  end


  def to_param #make program use slug instead of id in params.
    self.slug
  end

  def set_slug #makes slug from sluggable & adds a count to end if used prior
    slug = self.send(self.class.slug_column.to_sym).scan(/[a-zA-Z0-9]+/).join("-").downcase
    count = 1
    slugtest = slug
    while self.class.find_by(slug: slugtest) && (self.class.find_by(slug: slugtest) != self)
      slugtest = slug
      slugtest  += "_#{count}"
      count +=1
    end
    self.slug = slugtest
  end

  module ClassMethods
    def sluggable_column(column)
      self.slug_column = column
    end
  end
end
