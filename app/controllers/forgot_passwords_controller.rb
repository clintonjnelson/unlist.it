class ForgotPasswordsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user.present?
      @user.create_reset_token
      # UnlistMailer.password_reset_email(@user.id).deliver
      UnlistMailer.delay.password_reset_email(@user.id)
      render 'confirm_password_reset_email'
    else
      flash[:error] = "Incorrect Email. Please try again."
      render 'new'
    end
  end
end
