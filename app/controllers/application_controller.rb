class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :signed_in?, :current_user

  def access_denied(msg = "Access Denied.")
    flash[:error] = "#{msg}"
    redirect_to (signed_out? ? root_path : home_path)
  end

  def current_user
    User.find(session[:user_id]) if signed_in?
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

  def signin_user(user)
    session[:user_id] = user.id
    flash[:success] ||= "Welcome, #{user.username}!"
    redirect_to home_path
  end

end
