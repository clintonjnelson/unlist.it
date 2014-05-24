class UsersController < ApplicationController
before_action :require_signed_out, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UnlistMailer.confirmation_email(@user).deliver
      #UnlistMailer.delay.confirmation_email(@user.id)
      flash[:success] = "Welcome to Unlist!"
      signin_user(@user)
    else
      flash[:error] = "There were some errors in your information. Please see comments below."
      render 'new'
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :username)
    end
end
