class UnlistingsController < ApplicationController
  ##ADD THESE BEFORE ACTIONS TO SPECS
  before_action :set_current_user,          only: [:new, :create, :show, :edit, :update          ]
  before_action :set_unlisting,             only: [               :show, :edit, :update, :destroy]
  ###VERIFY ALREADY TESTED FOR THESE
  before_action :require_correct_user,      only: [                      :edit, :update, :destroy]
  before_action :require_signed_in,         only: [:new, :create,        :edit, :update, :destroy]
  before_action :filter_symbols_from_price, only: [      :create,               :update          ]
  before_action :format_link,               only: [      :create,               :update          ]

  def new #Loads: @user
    @unlisting = @user.unlistings.build
    @token     = build_token
  end

  def create #Loads: @user
    @unlisting = @user.unlistings.build(unlisting_params)
    @token     = unlisting_token_param[:token]
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
    @unlistings = Category.find(params[:category_id]).unlistings.active
    render 'pages/browse'
  end

  def show #Loads: @unlisting
    @message = Message.new
  end

  def edit #Loads: @unlisting, @user
    @token  = @unlisting.unimages_token
    @unimages = Unimage.where(token: @token).all
  end

  def update #Loads: @unlisting, @user
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
    @conditions = Condition.where(category_id: params[:category_id]).all
    respond_to do |format|
      format.any(:js, :html) {render 'unlistings/conditions_by_category.js.haml'}
    end
  end

  def show_message_form
    respond_to do |format|
      format.js { render }
    end
  end

  ################################ PRIVATE METHODS #############################
  private
  def set_unlisting
    @unlisting = Unlisting.find_by(slug: params[:id])
  end
  def require_correct_user
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

  def format_link
    url_string = unlisting_params[:link]
    if url_string.present?
      (url_string.starts_with?("http://") || url_string.starts_with?("https://")) ? url_string : (params[:unlisting][:link] = "http://#{url_string}")
    end
  end

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

  def unimage_ids_array
    @unimage_ids_array = @unlisting.unimages.map(&:id)
  end

  def build_token
    SecureRandom.urlsafe_base64
  end
end
