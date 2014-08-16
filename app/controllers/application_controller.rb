class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :signed_in?, :creator?, :current_user

  def access_denied(msg = "Access Denied.")
    flash[:error] = "#{msg}"
    redirect_to (signed_out? ? root_path : home_path)
  end

  def access_denied_now(msg = "Access Denied.")
    flash.now[:error] = "#{msg}"
    render partial: 'shared/flash_message_js.js.haml'
  end

  def current_user
    User.find(session[:user_id]) if signed_in?
  end

  def creator?(object)  #Works for Unposts,
    session[:user_id].present? ? session[:user_id] == object.creator.id : false
  end

  def guest_user?
    session[:user_id] == nil
  end

  def signed_in?
    session[:user_id].present?
  end

  def signed_out?
    session[:user_id].nil?
  end

  def require_signed_in
    access_denied("You must be signed in to do that.") unless signed_in?
  end

  def require_signed_out
    access_denied("You must be signed out to do that.") unless signed_out?
  end

  #verify the OR condition won't hijack functionality
  #TODO: Verify that isn't allowing users to mask themselves as another
  #Had issue because it was setting @user = current_user,
    #so when checked "require_correct_user", DIDN"T FAIL!
  def set_user
    if    params[:id]
      @user = User.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
    else
      #@user = current_user #Seems risky to EVER do this.
    end
    #@user = (params[:id] ? User.find(params[:id]) : (params[:user_id] ? User.find(params[:user_id]) : current_user) )
  end

  def set_current_user
    @user = current_user
  end

  def signin_user(user)
    session[:user_id] = user.id
    flash[:success] ||= "Welcome, #{user.username}!"
    redirect_to home_path
  end

end
