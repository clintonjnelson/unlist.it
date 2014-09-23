class UnlistingsController < ApplicationController
  ##ADD THESE BEFORE ACTIONS TO SPECS
  before_action :set_current_user,          only: [:new, :create, :show, :edit, :update          ]
  before_action :set_unlisting,             only: [               :show, :edit, :update, :destroy]
  ###VERIFY ALREADY TESTED FOR THESE
  before_action :require_correct_user,      only: [                      :edit, :update, :destroy]
  before_action :require_signed_in,         only: [:new, :create,        :edit, :update, :destroy]
  before_action :filter_symbols_from_price, only: [      :create,               :update          ]
  before_action :format_input_link,         only: [      :create,               :update          ]

  def new #Loads: @user
    @unlisting = @user.unlistings.build
    @token     = build_token
  end

  def create #Loads: @user
    @unlisting = @user.unlistings.build(unlisting_params)
    set_or_update_link_image_column

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

  def index   #for User Unlist
    case params[:type]
      when 'hits'
        #ORDER BY MOST RECENT MESSAGE - likely Join messages & order by created_at
        @unlistings = current_user.unlistings.hits
      when 'watchlist'
        # This probably warrants another table completely
      else
        @unlistings = current_user.unlistings.active
    end
    render 'index'
  end

  def index_by_category #for Browse Page Results
    @categories = Category.order('name ASC').all
    @category   = Category.find_by(slug: params[:category_id])
    @unlistings = @category.unlistings.active.paginate(page: params[:page])
    respond_to do |format|
      format.html { render 'pages/browse' }
      format.js   { render 'pages/browse.js.haml' }
    end
  end

  def show #Loads: @unlisting
    ## UPDATE SPECS FOR @allow_safeguest VARIABLE
    @allow_safeguest = UserPolicy.new(user: @unlisting.creator).safeguest_contact_allowed?
    @message = Message.new
  end

  def edit #Loads: @unlisting, @user
    @token  = @unlisting.unimages_token
    @unimages = Unimage.where(token: @token).all
  end

  def update #Loads: @unlisting, @user
    set_or_update_link_image_column

    if @unlisting && @unlisting.update(unlisting_params)
      flash[:success] = 'Unlisting Updated.'
      redirect_to [@user, @unlisting]
    else
      flash[:error] = 'Oops - there were some errors in the form. Please fix & try agian.'
      @unimages = Unimage.where(token: unlisting_token_param[:token]).all
      render 'edit'
    end
  end

  def destroy #Loads: @unlisting
    @unlisting.soft_delete
    UnimagesCleaner.perform_in(20.seconds, @unimage_ids_array)
    flash[:success] = "Unlisting successfully removed."
    redirect_to :back
  end


  ################################# AJAX ACTIONS ###############################

  def conditions_by_category
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

  ################################ PRIVATE METHODS #############################
  private
  ################################ BEFORE ACTIONS ##############################
  def set_unlisting
    @unlisting = Unlisting.find_by(slug: params[:id])
  end
  def require_correct_user
    binding.pry
    access_denied("You are not the owner of this unlisting.") unless @unlisting && (current_user == @unlisting.creator)
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
    formatted_url = format_url(url_string)
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
                                       :link)
  end

  def unlisting_token_param
    params.require(:unlisting).permit(:token)
  end

  def link_params
    params.fetch(:image_links, {}).permit('0', '1', '2', '3', '4', :link_radio_select, :use_thumb_image)
  end

  ############################### SUPPORT METHODS ##############################

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

  def set_thumbnail_links_array
    if url = format_url(params[:thumb_url])
      info = LinkThumbnailer.generate(url) #grab the info from the link
      @thumbnail_links = []
      info.images.each do |thumb|
        @thumbnail_links.push(thumb.src.to_s)
      end
    else
      return false
    end
  end

  def format_url(url_string)
    if url_string.present?
      return formatted_url = (url_string.starts_with?("http://") || url_string.starts_with?("https://")) ? url_string : "http://#{url_string}"
    else
      return false
    end
    #formatted_url
  end

  def unimage_ids_array
    @unimage_ids_array = @unlisting.unimages.map(&:id)
  end

  def build_token
    SecureRandom.urlsafe_base64
  end
end
