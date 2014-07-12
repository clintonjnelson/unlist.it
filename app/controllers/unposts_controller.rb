class UnpostsController < ApplicationController
  before_action :require_signed_in,    only: [:new, :create, :edit, :update, :destroy]
  before_action :require_correct_user, only: [               :edit, :update, :destroy]
  before_action :set_current_user,     only: [:create,       :edit, :update          ]
  skip_before_filter :verify_authenticity_token, only: [:create_unimage]

  def new
    @user     = current_user
    @unpost   = @user.unposts.build
    @token    = build_token
  end

  # TEMP controller for testing upload capabilities
  def create_unimage
    @unimage = Unimage.new(unimage_params)

    respond_to do |format|
      if @unimage.save
        #if @unimage can be saved, send a status 200 for confirmation to Dropzone of success
        ##### sends @unimage, but not sure it uses it
        #id is a reference used for deleting an uploaded image using the "remove" button
        format.json { render json: @unimage, id: @unimage.id, token: @unimage.token, :status => 200 }
      else
        #if @unimage CANNOT be saved, a status 400 for notification to Dropzone of failure
        ##### sends errors, but how to display?
        format.json { render json: { error: @unimage.errors.full_messages }, :status => 400 }
      end
    end
  end

  def create
    #####MODIFY THIS TO ADD TOKENS, AND LINK IMAGES TO THE UNPOST UPON CREATION
    @unpost = @user.unposts.build(unpost_params)
    unpost_unimages = Unimage.where(token: unpost_token_param[:token]).all
    @unpost.unimages << unpost_unimages
    if @user && @unpost.save

      #IMAGES UPLOADING - TO BECOME SERVICE
      # if unimages_params.present?
      #   if save_unimages
      #     flash[:success] = "Unpost created!"
      #     redirect_to [@user, @unpost]
      #   else
      #     flash[:error] = "There was an error with your image uploads. Please fix & try agian."
      #     render 'new'
      #   end
      # end
        flash[:success] = "Unpost created!"
        redirect_to [@user, @unpost]
    else
      flash[:error] = 'Oops - there were some errors in the form. Please fix & try agian.'
      render 'new'
    end
  end

  #TODO: UNPOSTS VIRTUAL ATTRIBUTE SHOULD AUTO FILTER INACTIVE UNPOSTS
  def index   #for User Unlist
    @unposts = current_user.unposts.select{|post| (post.inactive? == false)}
  end

  def index_by_category #for Browse Page Results
    @categories = Category.all
    @unposts = Category.find(params[:category_id]).unposts
    render 'pages/browse'
  end

  def show
    @user = current_user
    @unpost = Unpost.find(params[:id])
    @message = Message.new
  end

  def edit
    @unpost = Unpost.find(params[:id])
  end

  def update
    #DOESNT WORK TO UPDATE CONDITION UNTIL I FIGURE OUT AJAX FORM
    @unpost = Unpost.find(params[:id])
    if @unpost && @unpost.update(unpost_params)
      flash[:success] = 'Unpost Updated.'
      redirect_to [@user, @unpost]
    else
      flash[:error] = 'Oops - there were some errors in the form. Please fix & try agian.'
      render 'edit'
    end
  end

  def destroy
    @unpost.update_column(:inactive, true)
    flash[:success] = "Unpost successfully removed."
    redirect_to :back
  end

  ################################# NON-CRUD ###################################

  def search #TODO As Grows: SearchesController with QueryObject
    @search_string = search_params[:keyword]
    if search_params[:category_id] == "0"
      @search_category = "0"
      if Rails.env.development? || Rails.env.testing?
        @search_results = Unpost.where("keyword1 LIKE :search OR keyword2 LIKE :search OR keyword3 LIKE :search OR keyword4 LIKE :search",
                                    { search: "%#{search_params[:keyword]}%" }).all
      else
        @search_results = Unpost.where("keyword1 ILIKE :search OR keyword2 ILIKE :search OR keyword3 ILIKE :search OR keyword4 ILIKE :search",
                                    { search: "%#{search_params[:keyword]}%" }).all
      end
    else
      @search_category = Category.find(search_params[:category_id])
      if Rails.env.development? || Rails.env.testing?
        @search_results = Unpost.where("keyword1 LIKE :search OR keyword2 LIKE :search OR keyword3 LIKE :search OR keyword4 LIKE :search",
                                      { search: "%#{search_params[:keyword]}%" }).where(category_id: search_params[:category_id]).all
      else
        @search_results = Unpost.where("keyword1 ILIKE :search OR keyword2 ILIKE :search OR keyword3 ILIKE :search OR keyword4 ILIKE :search",
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
  def require_correct_user
    @unpost = Unpost.find(params[:id])
    access_denied("You are not the owner of this unpost.") unless @unpost && (current_user == @unpost.creator)
  end

  def unpost_params
    params.require(:unpost).permit( :category_id,
                                    :title,
                                    :description,
                                    :size,
                                    :condition_id,
                                    :price,
                                    :keyword1,
                                    :keyword2,
                                    :keyword3,
                                    :keyword4,
                                    :link)
                                    # :travel,
                                    # :distance,
                                    # :zipcode)
  end

  def unpost_token_param
    params.require(:unpost).permit(:token)
  end

  def build_token
    SecureRandom.urlsafe_base64
  end

  ###NEED TO TEST THIS IN SEPARATE FILE SAVING SERVICE
  ##THIS WAS USED FOR HTML REQUESTS AT TIME OF UNPOST SUBMIT TO ADD PHOTOS
  def save_unimages
    begin
      ActiveRecord::Base.transaction do
        unimage_params['filename'].each do |u|
          @unpost.unimages.create!(filename: u)
        end
      end
      return true
    rescue ActiveRecord::RecordInvalid
      return false
    end
  end

  #VERIFY MEETS SECURITY REQUIREMENTS
  ###CHANGES UNIMAGES ---> UNIMAGE
  def unimage_params
    params[:unimage].present? ? params.require(:unimage).permit(:filename, :token) : nil
    #params[:unimages].present? ? params.require(:unimages).permit(filename: []) : nil
    #params.require(:unimages).permit(filename: [])
  end

  def search_params
    params.permit(:keyword, :category_id)
  end
end
