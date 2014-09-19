class SessionsController < ApplicationController
before_filter :require_signed_in,  only: [:destroy]
before_filter :require_signed_out, only: [:create]

  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      signin_user(@user)
    else
      flash[:error] = "Incorrect Login Information. Please try again."
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice]    = "You're now signed out."
    redirect_to root_path
  end
end
