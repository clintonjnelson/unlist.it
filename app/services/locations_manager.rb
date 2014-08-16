class LocationsManager

  attr_reader :latitude, :longitude, :city, :state, :success, :type, :zipcode, :id
  def initialize()
  end

  def find_or_make_location(location_input)
    @location_input = location_input

    if is_zipcode? #if zipcode provided
      db_location = Location.where(zipcode: @location_input.to_i).take #try to find in db
      if db_location #if in db
        @id        = db_location.id
        @zipcode   = db_location.zipcode
        @latitude  = db_location.latitude
        @longitude = db_location.longitude
        @type     = "Zipcode"
        @success   = true
        return successful?
      else #if not in db, make new
        @location = Location.new(zipcode: @location_input.to_i)
        @type     = "Zipcode"
      end

    else #if location info provided
      city, state  = format_city_state #set city & state variables to downcase strings of each
      db_location  = Location.where(state: state).where(city: city).first #try to find location in db
      if db_location #if in db
        @id        = db_location.id
        @city      = db_location.city.capitalize
        @state     = db_location.state.upcase
        @latitude  = db_location.latitude
        @longitude = db_location.longitude
        @success   = true
        @type      = "Place"
        return successful?
      elsif city && state #if not in db
        @location  = Location.new(city: city, state: state) #make new location
        @type      = "Place"
      end
    end

    unless db_location #unless found existing, attempt to make new Location
      ##WHEN MAKE OOP, REALLY SHOULD SET A TYPE BASED ON INPUT
      ##SAVE ALL DATA & THEN PULL ZIP OR CiTY/STATE BASED IN TYPE
      if @location && @location.save #try to save new
        @id        = @location.id
        @latitude  = @location.reload.latitude
        @longitude = @location.reload.longitude
        case @type
          when "Place"
            @city    = @location.city.capitalize  #set city
            @state   = @location.state.upcase     #set state
          when "Zipcode"
            @zipcode = @location.zipcode
        end
        @success = true
        return successful?
      else
        @success = false
        return successful?
      end
    end
  end

  def successful?
    @success
  end

  def is_number?(value)
    !!(value =~ /\A[-+]?[0-9]+\z/)
  end

  def is_zipcode?
    is_number?(@location_input) && (@location_input.length == 5)
  end

  def format_city_state
    @location_input.downcase.gsub(/([^a-zA-Z]+)[\s+,\s+]/,",").split(",")
  end


end
