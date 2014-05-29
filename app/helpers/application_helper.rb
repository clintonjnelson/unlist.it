module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        'alert-success' #green, BS-v3
      when "notice"
        'alert-info'  #blue, BS-v3
      when "alert"
        'alert-warning' #yellow, BS-v3
      when "error"
        'alert-danger'  #red, BS-v3
    end
  end

  def gravatar_image(user, size=80)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.username, class: "gravatar")
  end

  BASE_CATEGORIES   = %w[ apartments autos boats clothing electronics games
    household jewelry jobs materials real\ estate services sporting\ goods ]
  UNPOST_CATEGORIES = ["please select category"] + BASE_CATEGORIES
  SEARCH_CATEGORIES = ["all categories"] + BASE_CATEGORIES
  UNPOST_CONDITIONS = %w[any poor fair average good very\ good excellent perfect new]
  UNPOST_TRAVEL_DISTANCE = %w[5 10 25 50 75 100 200 500 Any]
  def category_options
    options = ["please select category"] + Category.all.map{|category| [category.name, category.id]}
  end

  #Need this to be IN-PAGE dynamic using Ajax triggered by selection
  #Starts out saying "please select category", then from that picks the conditions available
  def condition_options
    options = ["please select category"] + Conditions.all.map{|condition| [condition.level, condition.id]}
  end

  def travel_distance_options
    options = ["please select distance"] + UNPOST_TRAVEL_DISTANCE.map.with_index(1).to_a
  end
  ##Takes a list of uposts and pulls all of the unique categories out into a list array
  # def category_array(unposts_set)
  #   category_array = []
  #   unposts_set.each do |unpost|
  #     category_array.push(unpost.category) unless
  #         ((unpost.category.nil?) || (unpost.category == "please select category"))
  #   end
  #   category_array.sort.uniq!
  #   #category_array.push(unposts_set.each(&:content)).uniq!
  # end
end
