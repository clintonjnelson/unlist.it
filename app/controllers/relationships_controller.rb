class RelationshipsController < ApplicationController
  before_action :set_user
  before_action :require_signed_in
  before_action :require_correct_user, only: [:create, :index, :destroy]

  def search
    @search_string = search_params[:search_string]
    @search_results = User.where( "email = :search or lower(username) = :search", search: "#{@search_string.downcase}" ).all if @search_string
    @searched = true
  end

  def create
    friend   = User.find_by(slug: relationship_params[:friend_slug])
    befriend = Relationship.new(user: current_user, friend: friend)
    if friend && befriend.save
      flash[:success] = "You're now following this person's unlist."
      redirect_to user_relationships_path(@user)
    else
      flash.now[:error] = "This person's unlist could not be added."
      render 'search'
    end
  end

  def index
    @friends = @user.friends
  end

  def destroy
    friend = User.find_by(slug: relationship_params[:friend_slug])
    current_user.friend_relationships.find_by(friend: friend).destroy
    flash[:success] = "You're no longer following that person's unlist."
    redirect_to user_relationships_path(@user)
  end

  private
  def require_correct_user
    access_denied("You are not the appropriate user.") unless (@user && current_user == @user)
  end

  def search_params
    params.permit(:search_string)
  end

  def relationship_params
    params.permit(:user_id, :friend_slug)
  end
end
