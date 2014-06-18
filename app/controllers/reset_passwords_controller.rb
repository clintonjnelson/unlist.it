class ResetPasswordsController < ApplicationController
  #Could make a before filter that requires a token in params (for redundancy)

  def create
    #
    #
    #
    #
    #
    #FINISH MAKING THIS & UPDATING THE COPIED SPECS FOR CREATE
    #
    #
    #
    #
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

  private
  def user_valid_but_token_expired?(timeframe = 2)
    @user && @user.expired_token?(timeframe)
  end

  def user_and_token_valid?(timeframe = 2)
    @user && !@user.expired_token?(timeframe)
  end
end
