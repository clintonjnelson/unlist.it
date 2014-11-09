#This Controller is NOT model backed.
class SearchesController < ApplicationController
  before_action :dev_test_env?

  def search
    set_search_options_variables
    @search_string   = search_params[:search_words]
    @search_category = ( (search_params[:category_id] == "0") ? "0" : Category.find(search_params[:category_id]) )
    @search_results  = UnlistingsQuery.new.search(search_string: @search_string,
                                              search_visibility: "everyone",
                                                    category_id: ((@search_category == "0") ? "0" : @search_category.id),
                                                         radius: session[:search_radius ],
                                                           city: session[:search_city   ],
                                                          state: session[:search_state  ],
                                                        zipcode: session[:search_zipcode] ).paginate(page: params[:page])
    respond_to do |format|
      format.html { render 'search' }
      format.js   { render 'search' } #for pagination
    end
  end

  ################################ SEARCH RADII## ##############################
  def search_radius #render modal form
    respond_to do |format|
      format.any(:html, :js) { render "search_radius_modal.js.erb"  }
    end
  end

  def remove_radius #removes radius from session
    session[:search_radius] = "0"
    @success = true
    respond_to do |format|
      format.any(:html, :js) { render 'searches/update_search_radius.js' }
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
      flash.now[:notice]  = "Sorry, we couldn't find that location. Please try a valid zipcode or city,state"
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
    params.permit(:search_words, :category_id, :search_by, :search_type, :comm_recycle)
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

  def set_search_options_variables
    [:search_by, :search_type, :comm_recycle].each do |item|
      self.instance_variable_set("@#{item}", search_params[item])
    end
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



  #####PAGINATING THE SEARCH RESULTS FOR MULTIPLE CATEGORIES#######
  ####ISSUE IS THAT STILL NEED TO BE ABLE TO LOAD MORE RESULTS FOR AN INDIVIDUAL CATEGORY
  ####BUT WHAT IF NO MORE RESULTS TO LOAD? SOUNDS LIKE A MESS OF CONDITIONALS FOR LOADING.
  ####It should break up the results into sections based on category_id
  ####Each of the tabs should be able to pull more results as necessary for that category
  ####it should load only the sections that the user clicks on - NOT INFINITE LOADING

  ####FROM CONTROLLER:

  # THIS SETS UP THE PARAMS BECAUSE IT WILL HAVE LOADED THE FIRST ALREADY AS THE LARGE ARRAY, NOT INDIVIDUALLY
    # params_page = ( (params[:load_more_pages].nil? ? params[:page] : (params[:page]) ) #THINK I NEED A +1 HERE!!
  # THIS SETS UP THE RESULTS LIMITED TO 3 PER CATEGORY USING THE INSTANCE METHODS BELOW.
    # If 0, should break up into results per category for loading pagination by category
    # if @search_category == "0"
    #   @search_results = build_paginated_results(@search_results, 3)
    # end

  # def build_paginated_results(initial_results, limit=10)
  #   build_category_array(initial_results).each do |category|
  #     final_results.push(initial_results.select{ |item| item.category.id == category.id }.first(limit))
  #   end
  #   final_results
  # end

  # def build_category_array(unlistings_set)
  #   category_array = []
  #   unlistings_set.each do |unlisting|
  #     category_array.push(unlisting.category) #unless unlisting.category.nil? #MAKE THIS ARRAY.NEW
  #   end
  #   category_array.sort.uniq
  # end

  ####FROM VIEW
    # Attempting to have a way to get at having link id available & ability to append to a specific class by category_id
      # %div{class: "search-category-#{category.id}", data: { category: category.id } }

    #Started on the link
      #=link_to "load more results", search_unlistings_path(category_id: category.id, keyword: @search_string, load_more_page: true), class: 'click-load', remote: true if @search_results.next_page
end
