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
    options = [["all categories", 0]] + (Category.order('name ASC').all.map{|category| [category.name.downcase, category.id]})#.sort{ |a,b| a[0] <=> b[0] }
  end

  def condition_options
    options = ["please select category"] + Conditions.all.map{|condition| [condition.level, condition.id]}
  end

  #Takes a list of uposts and pulls all of the unique categories out into a list array
  def category_array(unlistings_set)
    category_array = []
    unlistings_set.each do |unlisting|
      category_array.push(unlisting.category) #unless unlisting.category.nil?
    end
    category_array.sort.uniq
  end
  #unlistings_set.uniq.pluck(:category)
  #unlistings_set.pluck('DISTINCT category') #SQL form should be faster

  def kramdown(text)
    return sanitize Kramdown::Document.new(text).to_html
  end

  def search_placeholder(prior_search=nil)
    prior_search.present? ? prior_search : ''
  end

  def page_title(page_title)
    main_title = 'Unlist.it - Wishlist Classifieds'
    page_title.blank? ? "#{main_title}" : "#{main_title} | #{page_title}"
  end

  def page_description(page_description)
    main_description = "Combining the usefulness of a wishlist with the power of local classifieds. Your Unlist (wishlist) acts like a series of wanted ads, so local sellers can find you."
    page_description.blank? ? "#{main_description}" : "#{page_description}"
  end
end
