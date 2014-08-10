class LocationsController < ApplicationController

  def search_radius #render modal form
    respond_to do |format|
      format.html { render "search_radius.js.erb"  }
      format.js
    end
  end

  def set_search_radius
    if update_radius?
      flash.now[:success] = "Radius Updated."
    else
      flash.now[:notice]  = "Sorry, only numbers are allowed. Please try again."
    end

    respond_to do |format|
      format.js { render partial: 'shared/flash_message_js.js.haml' }
    end
  end

  def search_location #render modal form
    respond_to do |format|
      format.html { render 'search_location.js.erb' }
      format.js
    end
  end

  def set_search_location
    @location_param = location_param[:location]
    if update_location?
      flash.now[:success] = "Location Updated"
    else
      flash.now[:notice] = "Sorry, we couldn't find that location. Please try a valid zipcode or city,state"
    end

    respond_to do |format|
      format.html { render partial: 'shared/flash_message_js.js.haml' }
      format.js   { render partial: 'shared/flash_message_js.js.haml' }
    end
  end




  ################################ SUPPORT METHODS #############################
  private
  def radius_param
    params.permit(:radius)
  end

  def location_param
    params.permit(:location)
  end

  def update_radius?
    radius = radius_param[:radius]
    if radius.present? && is_number?(radius)
      session[:search_radius] = radius.to_i
      if signed_in?
        current_user.location.update(radius: radius.to_i)
      end
      true
    else
      false
    end
  end


  #THIS GEOCODING PORTION IS DEFINITELY LOOKING LIKE A SERVICE
  #######NEED TO FINISH GEOCODING
  def update_location?
    (@location_param.present? && geocode_and_store?) ? true : false
  end

  def geocode_and_store?
    if signed_in?
      ##DO STUFF
      # if is_zipcode?
      # else #assumed city,state or location
      # end
    else #if Guest
      set_session_from_new_or_existing ? true : false
    end
  end

  def is_number?(value)
    !!(value =~ /\A[-+]?[0-9]+\z/)
  end

  def is_zipcode?
    is_number?(@location_param) && (@location_param.length == 5)
  end

  def set_reverse_geo_location

  end

  def set_session_from_new_or_existing
    ##Try to find location in DB
    if is_zipcode? #if zipcode provided
      db_location = Location.where(zipcode: @location_param.to_i).take #try to find in db
      if db_location #if in db
        session[:search_zipcode  ] = db_location.zipcode
        session[:search_latitude ] = db_location.latitude
        session[:search_longitude] = db_location.longitude
        return true
      else #if not in db, make new
        @location           = Location.new(zipcode: @location_param.to_i)
        type = "Zipcode"
      end
    else #if location provided
      city, state = format_city_state #set city & state variables to downcase strings of each
      db_location = Location.where(state: state).where(city: city).first #try to find location in db
      if db_location #if in db
        session[:search_city     ] = db_location.city.capitalize
        session[:search_state    ] = db_location.state.upcase
        session[:search_latitude ] = db_location.latitude
        session[:search_longitude] = db_location.longitude
        return true
      elsif city && state #if not in db
        @location       = Location.new(city: city, state: state) #make new location
        type = "Place"
      end
    end

    unless db_location #unless found existing
      ##WHEN MAKE OOP, REALLY SHOULD SET A TYPE BASED ON INPUT
      ##SAVE ALL DATA & THEN PULL ZIP OR CiTY/STATE BASED IN TYPE
      if @location && @location.save #try to save new
        session[:search_latitude ] = @location.reload.latitude
        session[:search_longitude] = @location.reload.longitude
        case type
          when "Place"
            session[:search_city     ] = @location.city.capitalize  #set city
            session[:search_state    ] = @location.state.upcase     #set state
          when "Zipcode"
            session[:search_zipcode  ] = @location.zipcode
        end
      else
        false
      end
    end
  end


  def format_city_state
    @location_param.downcase.gsub(/\s+/,"").split(",")
  end
  # def set_session_values(options={})
  #   session[:search_location] = @location
  #   if location.is_a? Location
  #     session[:city] = @location
  #   else
  #     #REVERSE GEOCODE FOR CITY
  #     # session[:city]    =
  #     # session[:state]   =
  #   end
  # end
end
