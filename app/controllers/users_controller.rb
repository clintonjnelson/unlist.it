class UsersController < ApplicationController
  before_action :require_signed_out,       only: [:new, :create, :new_with_invite]
  before_action :require_signed_in,        only: [:show]
  before_action :set_user,                 only: [:show, :edit, :update, :toggle_avatar, :location_modal, :update_location] #MUST come before require_current_user
  before_action :require_correct_user,     only: [       :edit, :update, :toggle_avatar]
  before_action :require_correct_user_now, only: [:location_modal, :update_location]

##TODO:
####Create a Registration Service Object

  def new
    @user  = User.new
  end

  def new_with_invite  #temporary to be removed later
    @user  = User.new
    @token = params[:token]
    render 'new'
  end

  #ADD TOKEN TO CURRENT SIGNUP SHEET & ADD CONDITIONALS TO #CREATE ACTION

  def create
    @user  = User.new(user_params)
    @token = params[:token]                      #temporary to be removed later
    @invite = Invitation.find_by(token: @token)  #temporary to be removed later

    if @invite && @user.save
      Token.create(creator: @user, tokenable: @user)
      #UnlistMailer.registration_confirmation_email(@user.id).deliver
      UnlistMailer.delay.confirmation_email(@user.id)  #Sidekiq Worker
      @invite.set_redeemed                       #temporary to be removed later
      flash[:success] = "Welcome to Unlist! You have been sent an email to confirm registration. Please click the link in the email to complete your registration!"
      signin_user(@user)
    elsif !@invite
      flash[:error] = "Sorry, we could not find your invitation in our system.
                       Please contact the person who sent it to you or Unlist.it"
      redirect_to expired_link_path
    else
      flash[:error] = "There were some errors in your information. Please see comments below."
      render 'new'
    end
  end

  def show
    @unlistings = @user.unlistings.active if @user #load all active unlistings
  end

  def edit
  end

  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    if @user.update(user_params)
      flash[:success] = "Changes saved."
      redirect_to @user
    else
      flash[:error] = "Please fix the errors below & try saving again."
      render 'edit'
    end
  end


######################### CUSTOM(NON-CRUD) USER ACTIONS ######################
  def confirm_with_token
    token = Token.where(token: params[:token]).take
    user = User.find(token.user_id) if token
    if token && user
      user.update_attribute(:confirmed, true)
      token.update_attribute(:token, nil)
      #UnlistMailer.welcome_email(user.id).deliver
      UnlistMailer.delay.welcome_email(user) #Sidekiq Worker
      flash[:success] = "Thank you - your email has been confirmed! The Unlist.it world is now your oyster - help someone deliver you a pearl!"
      signed_in? ? (redirect_to home_path) : signin_user(user)
    else
      redirect_to invalid_address_path
    end
  end

  def toggle_avatar
    (avatar_params[:currently] == "true") ? @user.update_column(:use_avatar, false) : @user.update_column(:use_avatar, true)
    respond_to do |format|
      format.html { render edit_user_path(@user) }
      format.js   { render js: "window.location = '#{edit_user_path(@user)}'" }
    end
  end

  def location_modal
    respond_to do |format|
      format.any(:html, :js) { render 'user_location_modal.js.erb' }
    end
  end

  def update_location
    @location_param  = location_param[:location]
    location         = LocationsManager.new
    if @location_param.present? && location.find_or_make_location(@location_param)
      if update_user_location_and_variables?(location)
        flash.now[:success] = "Your default location has been updated."
      else
        flash.now[:notice]  = "Sorry, we couldn't update your location. Please try again."
      end
    else
      flash.now[:notice]  = "Sorry, we couldn't find that location. Please try a valid zipcode or city,state."
    end

    respond_to do |format|
      format.any(:html, :js) { render 'users/update_user_location.js.erb' }
    end
  end


############################## PRIVATE METHODS ###############################
private
  def user_params
    params.require(:user).permit(:email, :password, :username, :avatar, :avatar_cache)
  end

  def avatar_params
    params.permit(:id, :currently)
  end

  def location_param
    params.permit(:location)
  end

  def require_correct_user
    access_denied("You are not the appropriate user.") unless current_user == @user
  end

  def require_correct_user_now
    access_denied_now("You are not the appropriate user.") unless current_user == @user
  end

  def update_user_location_and_variables?(location)
    if @user.update(location_id: location.id)
      @success = true
      @city    = location.city
      @state   = location.state
      true
    else
      false
    end
  end
end
