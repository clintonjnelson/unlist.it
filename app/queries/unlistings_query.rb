#Query needa to be able to:
    # find unlistings with keywords as match; if no keywords, find all
    # filter by category; if no category - get all
    # filter by radius: if no radius, use only city or zipcode provided
    # filter by city,state or zipcode; default is Seattle, WA 98164


class UnlistingsQuery
  attr_reader :relation, :search_string, :category_id
  def initialize()
    dev_test_env?
  end


  def search(options={})
    @category_id   = options[:cateogory_id ]
    @city          = options[:city         ]
    set_radius(      options[:radius       ]) #Set default search radius or provided value
    @search_string = options[:search_string]
    @state         = options[:state        ]
      @city.downcase!  if @city
      @state.downcase! if @state
    @zipcode       = options[:zipcode      ]




    if @search_string  #if search string provided
      @relation = find_by_keyword(@search_string)
    else #if no search string, get all(?)
      @relation = Unlisting.active.all #gotta love Lazy Loading
    end

    if @category_id && (@category_id != "0") #if cateogory provided; category "0" means ALL
      @relation = with_category(@category_id)
    end

    if @radius != "0"  #If radius is NOT set to "0" (IN location), search for default or provided
      if @zipcode  #if zipcode for radius
        @relation = in_radius_of_zipcode(@zipcode, @radius)
      elsif @city && @state  #if place for radius
        @relation = in_radius_of_city_state(@city, @state, @radius)
      else
        @city     = "Seattle"
        @state    = "WA"
        @relation = in_radius_of_city_state(@city, @state, @radius)
      end
    elsif @zipcode  #if only zipcode provided & radius IS "0"
      @relation = in_zipcode
    elsif @city && @state  #if only place provided & radius IS "0"
      @relation = in_city_state
    # elsif @state #may want another option of JUST state
    #   @relation = in_state
    else #if no location provided, search IN default of Seattle,WA
      @city     = "Seattle"
      @state    = "WA"
      @relation = in_city_state
    end
    @relation.all
  end


  ################################# QUERY SCOPES ###############################
  def find_by_keyword(keyword)
    if @dev_test_env
      results = Unlisting.active.where("keyword1 LIKE :search OR keyword2 LIKE :search OR keyword3 LIKE :search OR keyword4 LIKE :search",
                           { search: "%#{keyword}%" }).order('created_at ASC')
    else
      results = Unlisting.active.where("keyword1 ILIKE :search OR keyword2 ILIKE :search OR keyword3 ILIKE :search OR keyword4 ILIKE :search",
                           { search: "%#{keyword}%" }).order('created_at ASC')
    end
    results
  end


  ############################### PRIVATE METHODS ##############################
  private
  def dev_test_env?
    @dev_test_env = true if (Rails.env.development? || Rails.env.test?)
  end

  def set_radius(value)
    value.nil? ? (@radius = 100) : (@radius = value)
  end

  def with_category(category_id)
    @relation.where(category_id: category_id)
  end

  #Find related Unlistings with creator in @zipcode.
  def in_zipcode
    @relation.joins(:creator => :location).where(locations: {zipcode: @zipcode})
  end

  #Find related Unlistings with creators in @city,@state
  def in_city_state
    @relation.joins(:creator => :location).where(locations: {state: @state}).where(locations: {city: @city})
  end

  #Find related Unlistings with creators nearby to @zipcode
  def in_radius_of_zipcode(zipcode, radius)
    nearbys = Location.near("#{zipcode}", radius, order: "distance")
    @relation.joins(:creator => :location).where(locations: { id: nearbys.map(&:id) })
  end

  #Find related Unlistings with creators nearby to @city,@state
  def in_radius_of_city_state(city, state, radius)
    nearbys = Location.near("#{[city,state].join(',')}", radius, order: "distance")
    @relation.joins(:creator => :location).where(locations: { id: nearbys.map(&:id) })
  end

end
