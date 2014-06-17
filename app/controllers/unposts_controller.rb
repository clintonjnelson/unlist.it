class UnpostsController < ApplicationController
  before_action :require_signed_in,    only: [:new, :create]

  def new
    @user = current_user
    @unpost = @user.unposts.build
  end

  def create
    @user = current_user
    @unpost = @user.unposts.build(unpost_params)
    if @user && @unpost.save
      flash[:success] = 'Unpost Created!'
      redirect_to [@user, @unpost]
    else
      flash[:error] = 'Oops - there were some errors in the for. Please fix & try agian.'
      render 'new'
    end
  end

  def index
    @unposts = current_user.unposts
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

  ################################# NON-CRUD ###################################

  def search #TODO As Grows: SearchesController with QueryObject
    @search_string = search_params[:keyword]
    if search_params[:category_id] == "0"
      @search_category = "0"
      @search_results = Unpost.where("keyword1 LIKE :search OR keyword2 LIKE :search OR keyword3 LIKE :search OR keyword4 LIKE :search",
                                    { search: "%#{search_params[:keyword]}%" }).all
    else
      @search_category = Category.find(search_params[:category_id])
      @search_results = Unpost.where("keyword1 LIKE :search OR keyword2 LIKE :search OR keyword3 LIKE :search OR keyword4 LIKE :search",
                                    { search: "%#{search_params[:keyword]}%" }).where(category_id: search_params[:category_id]).all
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
                                    :link,
                                    :travel,
                                    :distance,
                                    :zipcode)
  end

  def search_params
    params.permit(:keyword, :category_id)
  end
end
