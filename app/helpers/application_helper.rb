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

  # # Unpost Constants & Methods
  # BASE_CATEGORIES = %w[ apartments autos boats clothing electronics games
  #   household jewelry jobs materials real\ estate services sporting\ goods ]

  # UNPOST_CATEGORIES = ["please select category"] + BASE_CATEGORIES

  # SEARCH_CATEGORIES = ["all categories"] + BASE_CATEGORIES

  # #Takes a list of uposts and pulls all of the unique categories out into a list array
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
