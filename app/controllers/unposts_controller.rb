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

  def show
    @user = current_user
    @unpost = Unpost.find(params[:id])
  end

  def conditions_by_category
    @conditions = Condition.where(category_id: params[:category_id]).all
    respond_to do |format|
      format.js {render 'conditions_by_category'}
    end
  end

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
end
