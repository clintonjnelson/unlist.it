class SafeguestsController < ApplicationController

  def create
    @safeguest = Safeguest.where(confirm_token: safeguest_params[:token]).take
    if @safeguest && !@safeguest.token_expired?
      @safeguest.confirm_safeguest
      redirect_to safeguestsuccess_path
    else
      redirect_to expired_link_path
    end
  end

  private
  def safeguest_params
    params.permit(:token)
  end
end
