class UsersController < ApplicationController
before_action :require_signed_out, only: [:new, :create]
##TODO:
####Create a Registration Service Object

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      Token.create(creator: @user, tokenable: @user)
      UnlistMailer.confirmation_email(@user).deliver
      #UnlistMailer.delay.confirmation_email(@user.id)
      flash[:success] = "Welcome to Unlist! You have been sent an email to confirm registration. Please click the link in the email to complete your registration!"
      signin_user(@user)
    else
      flash[:error] = "There were some errors in your information. Please see comments below."
      render 'new'
    end
  end

  def confirm_with_token
    token = Token.where(token: params[:token]).take
    user = User.find(token.user_id) if token
    if token && user
      user.update_attribute(:confirmed, true)
      token.update_attribute(:token, nil)
      flash[:success] = "Thank you - your email has been confirmed! The Unlist world is now your oyster - help someone deliver you a pearl!"
      signed_in? ? (redirect_to home_path) : signin_user(user)
    else
      redirect_to invalid_address_path
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :username)
    end
end
