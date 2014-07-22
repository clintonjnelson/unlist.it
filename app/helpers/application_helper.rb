module ApplicationHelper
  UNPOST_TRAVEL_DISTANCE = %w[5 10 25 50 75 100 200 500 Any]


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

  def category_options
    options = [["please select category", 0]] + Category.all.map{|category| [category.name, category.id]}
  end

  #Need this to be IN-PAGE dynamic using Ajax triggered by selection
  #Starts out saying "please select category", then from that picks the conditions available
  def condition_options
    options = ["please select category"] + Conditions.all.map{|condition| [condition.level, condition.id]}
  end

  def travel_distance_options
    options = ["please select distance"] + UNPOST_TRAVEL_DISTANCE.map.with_index(1).to_a
  end
  #Takes a list of uposts and pulls all of the unique categories out into a list array
  def category_array(unposts_set)
    #unposts_set.uniq.pluck(:category)
    #unposts_set.pluck('DISTINCT category') #SQL form should be faster
    category_array = []
    unposts_set.each do |unpost|
      category_array.push(unpost.category) unless unpost.category.nil?
    end
    category_array.sort.uniq!
  end

  def search_placeholder(prior_search=nil)
    prior_search.present? ? prior_search : ''
  end
end

  # def gravatar_image(user, size=80)
  #   gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
  #   gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=mm"
  #   image_tag(gravatar_url, alt: user.username, class: "gravatar")
  # end
