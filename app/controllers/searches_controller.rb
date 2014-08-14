#This Controller is NOT model backed.
class SearchesController < ApplicationController
  before_action :dev_test_env?

  #TODO As Grows: SearchesController with QueryObject
  #OR Could just put into model until it's large enough to warrant search object
  def search
    @search_string   = search_params[:keyword]
    @search_category = ( (search_params[:category_id] == "0") ? "0" : Category.find(search_params[:category_id]) )
    @search_results  = UnpostsQuery.new.search(search_string: @search_string,
                                                cateogory_id: search_params[:category_id],
                                                      radius: nil,#session[:search_radius ],
                                                        city: session[:search_city   ],
                                                       state: session[:search_state  ],
                                                     zipcode: session[:search_zipcode] )
    render 'search'
  end

  ################################ SEARCH RADII## ##############################
  def search_radius #render modal form
    respond_to do |format|
      format.any(:html, :js) { render "search_radius_modal.js.erb"  }
    end
  end

  def set_search_radius
    if update_radius?
      @success = true
      flash.now[:success] = "Radius Updated."
    else
      flash.now[:notice]  = "Sorry, only numbers are allowed. Please try again."
    end

    respond_to do |format|
      format.any(:html, :js) { render 'searches/update_search_radius.js' }
    end
  end

  ############################## SEARCH LOCATIONS ##############################
  def search_location #render modal form
    respond_to do |format|
      format.any(:html, :js) { render 'search_location_modal.js.erb' }
    end
  end

  def set_search_location
    @location_param  = location_param[:location]
    location         = LocationsManager.new
    if @location_param.present? && location.find_or_make_location(@location_param)
      @success = true
      set_location_sessions(location)
      flash.now[:success] = "Location Updated"
    else
      flash.now[:notice] = "Sorry, we couldn't find that location. Please try a valid zipcode or city,state"
    end

    respond_to do |format|
      format.any(:html, :js) { render 'searches/update_search_location.js' }
    end
  end




  ################################ PRIVATE METHODS #############################
  private
  def dev_test_env?
    @dev_test_env = true if (Rails.env.development? || Rails.env.test?)
  end

  def search_params
    params.permit(:keyword, :category_id, :radius, :city, :state, :zipcode)
  end

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

  def is_number?(value)
    !!(value =~ /\A[-+]?[0-9]+\z/)
  end

  def set_location_sessions(location)
    case location.type
      when "Place"
        session[:search_city   ] = location.city
        session[:search_state  ] = location.state
        session[:search_zipcode] = nil
      when "Zipcode"
        session[:search_zipcode] = location.zipcode
        session[:search_city   ] = nil
        session[:search_state  ] = nil
    end
    session[:search_latitude   ] = location.latitude
    session[:search_longitude  ] = location.longitude
  end

  # def query_unposts(search_string, category_id="0")
  #   if @dev_test_env
  #     search_query = Unpost.active.where("keyword1 LIKE :search OR keyword2 LIKE :search OR keyword3 LIKE :search OR keyword4 LIKE :search",
  #                                       { search: "%#{search_string}%" })
  #   else
  #     search_query = Unpost.active.where("keyword1 ILIKE :search OR keyword2 ILIKE :search OR keyword3 ILIKE :search OR keyword4 ILIKE :search",
  #                                       { search: "%#{search_string}%" })
  #   end
  #   search_query = search_query.where(category_id: category_id) unless category_id == "0"
  #   nearby_user_ids = LocationsManager.new.nearby_users(location, radius)
  #   #NEED TO PULL A LIST OF NEARBY USERS BASED ON DEFAULT CITY, PROVIDED ZIPCODE, PROVIDED CITY, OR PROVIDED RADIUS FROM CITY
  #   #FILTER THESE RESULTS BY THE NEARBY ONES


  #   @search_results = search_query.all
  # end
end
