class Location < ActiveRecord::Base
  has_many :users

  #Geocoding - Checks results for success & sets error if no results
  geocoded_by         :provided_location do |obj, results|
    if results.first.blank?
      obj.errors.add(:base, "Could Not Find Location")
    else
      geo           = results.first
      obj.latitude  = geo.latitude
      obj.longitude = geo.longitude
      obj.city      = geo.city.downcase           #always want city/state for reference via input w/zip
      obj.state     = geo.state_code.downcase     #always want city/state for reference via input w/zip
    end
  end
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.city    = geo.city
      obj.state   = geo.state
      obj.zipcode = geo.postal_code
    end
  end

  # Callbacks
  after_validation    :geocode, :if => lambda { |obj| obj.zipcode_changed? || obj.city_changed? || obj.state_changed? }
  # Validations
  validates :zipcode, numericality: { only_integer: true },
                            length: {           is: 5    },
                       allow_blank:           true
  validates :state,         length: {           is: 2    },
                                       allow_blank: true

  private
  def provided_location
    city_state = [self.city, self.state].join(',')
    self.zipcode || city_state
  end
end
