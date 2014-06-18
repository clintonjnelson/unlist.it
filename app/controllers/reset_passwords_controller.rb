class ResetPasswordsController < ApplicationController
  #Could make a before filter that requires a token in params (for redundancy)

  def create
    @user = User.where(prt: params[:token]).take
    if user_valid_but_token_expired?
      @user.clear_reset_token
      redirect_to expired_password_reset_path
    elsif user_and_token_valid?
      update_with_valid_password_or_retry
    else
      redirect_to root_path
    end
  end

  def show
    @user = User.where(prt: params[:id]).take
    if user_valid_but_token_expired?
      @user.clear_reset_token
      redirect_to expired_password_reset_path
    elsif user_and_token_valid?
      @token = @user.prt
      render 'show' #could delete this line
    else
      redirect_to root_path
    end
  end


  ############################### PRIVATE METHODS ##############################
  private
  def password_change_params
    params.permit(:password)
  end

  def user_valid_but_token_expired?(timeframe = 2)
    @user && @user.expired_token?(timeframe)
  end

  def user_and_token_valid?(timeframe = 2)
    @user && !@user.expired_token?(timeframe)
  end

  def update_with_valid_password_or_retry
    if @user.update(password: params[:password])
      @user.clear_reset_token
      flash[:success] = 'Your password has been changed. You may now use it to login.'
      redirect_to root_path
    else
      flash[:error] = 'Your new password is not usable. Please try again'
      render 'show'
    end
  end
end
