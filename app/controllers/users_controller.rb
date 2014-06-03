class UsersController < ApplicationController
before_action :require_signed_out,    only: [:new, :create]
before_action :require_signed_in,     only: [:show]
before_action :set_user,              only: [:show, :edit, :update] #MUST come before require_current_user
before_action :require_correct_user,  only: [:show, :edit, :update]

##TODO:
####Create a Registration Service Object

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      Token.create(creator: @user, tokenable: @user)
      UnlistMailer.confirmation_email(@user.id).deliver
      #UnlistMailer.delay.confirmation_email(@user.id)  #Sidekiq Worker
      flash[:success] = "Welcome to Unlist! You have been sent an email to confirm registration. Please click the link in the email to complete your registration!"
      signin_user(@user)
    else
      flash[:error] = "There were some errors in your information. Please see comments below."
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Changes saved."
      redirect_to @user
    else
      flash[:error] = "Please fix the errors below & try saving again."
      render 'edit'
    end
  end

######################### CUSTOM(NON-CRUD) USER ACTIONS ########################
  def confirm_with_token
    token = Token.where(token: params[:token]).take
    user = User.find(token.user_id) if token
    if token && user
      user.update_attribute(:confirmed, true)
      token.update_attribute(:token, nil)
      UnlistMailer.welcome_email(user.id).deliver
      ##UnlistMailer.delay.welcome_email(user) #Sidekiq Worker
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

    def require_correct_user
      access_denied("You are not the appropriate user.") unless current_user == @user
    end
end