class UnpostsController < ApplicationController
  ##ADD THESE BEFORE ACTIONS TO SPECS
  before_action :set_current_user,     only: [:new, :create, :show, :edit, :update          ]
  before_action :set_unpost,           only: [               :show, :edit, :update, :destroy]
  ###VERIFY ALREADY TESTED FOR THESE
  before_action :require_correct_user, only: [                      :edit, :update, :destroy]
  before_action :require_signed_in,    only: [:new, :create,        :edit, :update, :destroy]



  def new #Loads: @user
    @unpost   = @user.unposts.build
    @token    = build_token
  end

  def create #Loads: @user
    @unpost = @user.unposts.build(unpost_params)
    @token  = unpost_token_param[:token]
    unpost_unimages = Unimage.where(token: @token).all
    @unpost.unimages << unpost_unimages

    if @user && @unpost.save
        flash[:success] = "Unpost created!"
        redirect_to [@user, @unpost]
    else
      flash[:error] = 'Oops - there were some errors in the form. Please fix & try agian.'
      @unimages = unpost_unimages #show any images for deletion on re-render
      render 'new'
    end
  end

  def index   #for User Unlist
    case params[:type]
      when 'hits'
        #ORDER BY MOST RECENT MESSAGE - likely Join messages & order by created_at
        @unposts = current_user.unposts.hits
      when 'watchlist'
        # This probably warrants another table completely
      else
        @unposts = current_user.unposts.active
    end
    render 'index'
  end

  def index_by_category #for Browse Page Results
    @categories = Category.all
    @unposts = Category.find(params[:category_id]).unposts.active
    render 'pages/browse'
  end

  def show #Loads: @unpost
    @message = Message.new
  end

  def edit #Loads: @unpost, @user
    @token  = @unpost.unimages_token
    @unimages = Unimage.where(token: @token).all
  end

  def update #Loads: @unpost, @user
    if @unpost && @unpost.update(unpost_params)
      flash[:success] = 'Unpost Updated.'
      redirect_to [@user, @unpost]
    else
      flash[:error] = 'Oops - there were some errors in the form. Please fix & try agian.'
      @unposts = Unimage.where(token: unpost_token_param[:token]).all
      render 'edit'
    end
  end

  def destroy #Loads: @unpost
    @unpost.update_column(:inactive, true)
    UnimagesCleaner.perform_in(20.seconds, @unimage_ids_array)
    flash[:success] = "Unpost successfully removed."
    redirect_to :back
  end


  ################################# NON-CRUD ###################################

  #TODO As Grows: SearchesController with QueryObject
  #OR Could just put into model until it's large enough to warrant search object
  def search
    @search_string = search_params[:keyword]
    if search_params[:category_id] == "0"
      @search_category = "0"
      if Rails.env.development? || Rails.env.test?
        @search_results = Unpost.active.where("keyword1 LIKE :search OR keyword2 LIKE :search OR keyword3 LIKE :search OR keyword4 LIKE :search",
                                    { search: "%#{search_params[:keyword]}%" }).all
      else
        @search_results = Unpost.active.where("keyword1 ILIKE :search OR keyword2 ILIKE :search OR keyword3 ILIKE :search OR keyword4 ILIKE :search",
                                    { search: "%#{search_params[:keyword]}%" }).all
      end
    else
      @search_category = Category.find(search_params[:category_id])
      if Rails.env.development? || Rails.env.test?
        @search_results = Unpost.active.where("keyword1 LIKE :search OR keyword2 LIKE :search OR keyword3 LIKE :search OR keyword4 LIKE :search",
                                      { search: "%#{search_params[:keyword]}%" }).where(category_id: search_params[:category_id]).all
      else
        @search_results = Unpost.active.where("keyword1 ILIKE :search OR keyword2 ILIKE :search OR keyword3 ILIKE :search OR keyword4 ILIKE :search",
                                      { search: "%#{search_params[:keyword]}%" }).where(category_id: search_params[:category_id]).all
      end

    end
    render 'search'
  end

  ################################# AJAX ACTIONS ###############################

  def conditions_by_category
    @conditions = Condition.where(category_id: params[:category_id]).all
    respond_to do |format|
      format.js {render 'conditions_by_category'}
    end
  end

  def show_message_form
    respond_to do |format|
      format.js { render }
    end
  end

  ################################ PRIVATE METHODS #############################
  private
  ################################ BEFORE FILTERS ##############################
  def set_unpost
    @unpost = Unpost.find(params[:id])
  end
  def require_correct_user
    access_denied("You are not the owner of this unpost.") unless @unpost && (current_user == @unpost.creator)
  end

  def unpost_params
    params.require(:unpost).permit( :category_id,
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

  def unpost_token_param
    params.require(:unpost).permit(:token)
  end

  def search_params
    params.permit(:keyword, :category_id)
  end

  def unimage_ids_array
    @unimage_ids_array = @unpost.unimages.map(&:id)
  end

  def build_token
    SecureRandom.urlsafe_base64
  end
end
