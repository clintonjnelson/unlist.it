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

  def category_options
    options = [["please select category", 0]] + Category.all.map{|category| [category.name, category.id]}
  end

  #Need this to be IN-PAGE dynamic using Ajax triggered by selection
  #Starts out saying "please select category", then from that picks the conditions available
  def condition_options
    options = ["please select category"] + Conditions.all.map{|condition| [condition.level, condition.id]}
  end

  #Takes a list of uposts and pulls all of the unique categories out into a list array
  def category_array(unposts_set)
    #unposts_set.uniq.pluck(:category)
    #unposts_set.pluck('DISTINCT category') #SQL form should be faster
    category_array = []
    unposts_set.each do |unpost|
      category_array.push(unpost.category) #unless unpost.category.nil?
    end
    category_array.sort.uniq
  end

  def search_placeholder(prior_search=nil)
    prior_search.present? ? prior_search : ''
  end
end
