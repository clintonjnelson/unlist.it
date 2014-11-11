class UnlistingsController < ApplicationController
  ##ADD THESE BEFORE ACTIONS TO SPECS
  before_action :set_user,                  only: [:new, :create, :index, :edit, :update, :destroy]
  before_action :set_unlisting,             only: [               :show,  :edit, :update, :destroy]
  ###VERIFY ALREADY TESTED FOR THESE
  before_action :require_signed_in,         only: [:new, :create,         :edit, :update, :destroy]
  before_action :require_correct_user,      only: [:new, :create                                  ]
  before_action :require_creator_user,      only: [                       :edit, :update, :destroy]
  before_action :filter_symbols_from_price, only: [      :create,                :update          ]
  before_action :format_input_link,         only: [      :create,                :update          ]

  def new
    @unlisting = @user.unlistings.build
    @token     = build_token
  end

  def create #Loads: @user
    @unlisting = @user.unlistings.build(unlisting_params)
    set_or_update_link_image_column
    binding.pry

    #Load images from token & save token
    @token                    = unlisting_token_param[:token]
    unlisting_unimages        = Unimage.where(token: @token).all
    @unlisting.unimages       << unlisting_unimages
    @unlisting.unimages_token = @token

    if @user && @unlisting.save
      flash[:success] = "Unlisting created!"
      redirect_to [@user, @unlisting]
    else
      flash[:error] = 'Oops - there were some errors in the form. Please fix & try agian.'
      @unimages = unlisting_unimages #show any images for management on re-render
      render 'new'
    end
  end

  def index   #for User Unlist ____VERIFY THIS WONT RUIN LOOKING AT OTHERS UNLISTS
    if correct_user || creator_user
      case params[:type]
        when 'hits'
          #ORDER BY MOST RECENT MESSAGE - likely Join messages & order by created_at
          @unlistings = current_user.unlistings.order('created_at DESC').hits
        when 'found'
          @unlistings = current_user.unlistings.found.order('updated_at DESC')
        when 'watchlist'
          # This probably warrants another table completely
        else
          @unlistings = current_user.unlistings.order('created_at DESC').active
      end
    else
      redirect_to browse_category_path("All")
      return
    end
    render 'index'
  end

  def index_by_category #for Browse Page Results
    @categories = Category.order('name ASC').all
    set_category
    set_unlistings
    respond_to do |format|
      format.html { render 'pages/browse'         }
      format.js   { render 'pages/browse.js.haml' }
    end
  end

  def show #Loads: @unlisting
    ## UPDATE SPECS FOR @allow_safeguest VARIABLE
    @allow_safeguest = UserPolicy.new(user: @unlisting.creator).safeguest_contact_allowed?
    @message         = Message.new
  end

  def edit #Loads: @unlisting, @user
    @token    = @unlisting.unimages_token
    @unimages = Unimage.where(token: @token).all
  end

  def update #Loads: @unlisting, @user
    set_or_update_link_image_column
    binding.pry

    if @unlisting && @unlisting.update(unlisting_params)
      flash[:success] = 'Unlisting Updated.'
      redirect_to [@user, @unlisting]
    else
      flash[:error] = 'Oops - there were some errors in the form. Please fix & try agian.'
      @unimages     = Unimage.where(token: unlisting_token_param[:token]).all
      render 'edit'
    end
  end

  def destroy #Loads: @unlisting
    @unlisting.soft_delete #ORDER MATTERS - must come before set_found
    @unlisting.set_found   if (params[:found] == "true")
    UnimagesCleaner.perform_in(20.seconds, @unimage_ids_array)
    flash[:success] = ((params[:found] == "true") ? "Yay - we celebrate when you find things!" : "Unlisting successfully removed.")
    redirect_to :back
  end


  ################################# AJAX ACTIONS ###############################

  def conditions_by_category
    @current = params[:condition].to_i #value here from the JQUERY
    @conditions = Condition.order('position ASC').where(category_id: params[:category_id]).all
    respond_to do |format|
      format.any(:js, :html) {render 'unlistings/conditions_by_category.js.haml'}
    end
  end

  def show_message_form
    respond_to do |format|
      format.js { render }
    end
  end

  def show_thumbnails
    #COULD TURN THIS INTO A SERVICE/MANAGER THAT RETURNS JUST THE ARRAY OF LINKS
    @unlisting = Unlisting.find_by(slug: params[:unlisting_slug])
    set_thumbnail_links_array

    respond_to do |format|
      format.any(:js) { render 'unlistings/show_thumbnails.js.erb'  }
    end
  end


  private ######################## PRIVATE METHODS #############################
  ################################ BEFORE ACTIONS ##############################
  def set_unlisting
    @unlisting = Unlisting.find_by(slug: params[:id])
    access_denied("That is not a proper unlisting address.") unless @unlisting
  end

  def require_correct_user
    access_denied("You are not the correct user.") unless correct_user
  end

  def require_creator_user
    access_denied("You are not the owner of this unlisting.") unless creator_user
  end

  def filter_symbols_from_price
    if params[:unlisting][:price].present?
      price_string = params[:unlisting][:price]
      price_string.gsub!('$', '')
      price_string.gsub!(',', '')
      price_string.to_i ? (params[:unlisting][:price] = price_string.to_i) : true #true so can throw validation error later
    end
  end

  def format_input_link
    url_string    = unlisting_params[:link]
    formatted_url = format_url(url_string, true) #make amazon unlist link if there is one
    params[:unlisting][:link] = formatted_url unless (url_string == formatted_url)
  end

  #################################### PARAMS ##################################
  def unlisting_params
    params.require(:unlisting).permit( :category_id,
                                       :title,
                                       :description,
                                       :condition_id,
                                       :price,
                                       :keyword1,
                                       :keyword2,
                                       :keyword3,
                                       :keyword4,
                                       :link,
                                       :visibility)
  end

  def unlisting_token_param
    params.require(:unlisting).permit(:token)
  end

  def link_params
    params.fetch(:image_links, {}).permit('0', '1', '2', '3', '4', '5', '6', '7', :link_radio_select, :use_thumb_image)
  end

  ############################### SUPPORT METHODS ##############################
  def correct_user
    @user && (@user == current_user)
  end

  def creator_user
    @unlisting && (@unlisting.creator == current_user)
  end


  #This loads variables for the browse page depending on selection/default
  def set_category
    @category = ( params[:category_id] == "All" ? "All" : Category.find_by(slug: params[:category_id]) )
  end

  def set_unlistings
    if @category  == "All"
      @unlistings = Unlisting.order('created_at DESC').active.paginate(page: params[:page])
    elsif @category.present?
      @unlistings = @category.unlistings.active.paginate(page: params[:page])
    end
  end


  #This manages the setting & updating of external image links for Unlistings
  def set_or_update_link_image_column
    if link_params[:use_thumb_image].nil? #remove if user un-checks the box
      @unlisting.link_image = nil
    elsif @unlisting.link_image == link_params[:use_thumb_image] #NO change, if they match
      return
    else #check if any of the bullets are selected
      if link_params[:link_radio_select].nil? #if none was selected, default to NO change
        return
      else #if one was selected, update for it
        @unlisting.link_image = link_params[link_params[:link_radio_select]]
      end
    end
  end

  #LinkManager OBJECT?
  def set_thumbnail_links_array
    if url = format_url(params[:thumb_url])
      @thumbnail_links = []
      if amazon_link?(url) #if amazon link, use API to set image url
        @thumbnail_links.push(@amazon_ecs.get_product_image)
      else #set image url's from site
        info = LinkThumbnailer.generate(url)
        info.images.each do |thumb|
          @thumbnail_links.push(thumb.src.to_s)
        end
      end
    else
      return false
    end
  end

  #LinkManager OBJECT?
  def format_url(url_string, associate_link=nil)
    if url_string.present?
      formatted_url   = (url_string.starts_with?("http://") || url_string.starts_with?("https://")) ? url_string : "http://#{url_string}"
      if amazon_link?(formatted_url) #if amazon link, use API to format a base url
        @amazon_ecs   = AmazonecsManager.new(url: formatted_url)
        formatted_url = (associate_link.blank? ? @amazon_ecs.amazon_link : @amazon_ecs.amazon_link(nil, true))
      end
      formatted_url
    else
      return nil
    end
  end

  def amazon_link?(url)
    url.include?("amazon.com") || url.include?("amzn.com")
  end

  def unimage_ids_array
    @unimage_ids_array = @unlisting.unimages.map(&:id)
  end

  def build_token
    SecureRandom.urlsafe_base64
  end
end
