class SessionsController < ApplicationController
before_filter :require_signed_in, only: [:destroy]
before_filter :require_signed_out, only: [:create]

  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      flash[:success] = "Welcome, #{@user.username}!"
      session[:user_id] = @user.id
    else
      flash[:error] = "Incorrect Login Information. Please try again."
    end
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "You're now signed out."
  end
end
