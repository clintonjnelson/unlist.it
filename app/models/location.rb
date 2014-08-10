class Location < ActiveRecord::Base
  belongs_to :user

  #Geocoding - Checks results for success & sets error if no results
  geocoded_by         :provided_location do |obj, results|
    if results.first.blank?
      obj.errors.add(:base, "Could Not Find Location")
    else
      geo           = results.first
      obj.latitude  = geo.latitude
      obj.longitude = geo.longitude
    end
  end
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.city    = geo.city
      obj.state   = geo.state
      obj.zipcode = geo.postal_code
    end
  end
  after_validation    :geocode,  :if => lambda { |obj| obj.zipcode_changed? || obj.city_changed? || obj.state_changed? }
  #before_save         :verify_success


  validates :zipcode, numericality: { only_integer: true },
                                       allow_blank: true
  validates :state,         length: {           is: 2    },
                                       allow_blank: true

  private
  def provided_location
    city_state = [self.city, self.state].join(',')
    self.zipcode || city_state
  end

  def verify_success

  end
end
