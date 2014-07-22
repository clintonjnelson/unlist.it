class UnimagesController < ApplicationController
  before_action :require_signed_in,              only: [:create, :destroy]
  before_action :require_correct_user,           only: [:destroy         ]
  skip_before_filter :verify_authenticity_token, only: [:create          ]

  ###### NEED SPECS FOR THIS CONTROLLER!!!!

  def create
    @unimage = current_user.unimages.reload.build(unimage_create_params)
    respond_to do |format|
      if @unimage.save
        # id/token for remove button; senda status 200 OK for Dropzone success
        format.json { render json: @unimage, id: @unimage.id, token: @unimage.token, :status => 200 }
      else
        #errors for display --HOW??--, status 400 ERROR for Dropzone failure
        format.json { render json: { error: @unimage.errors.full_messages }, :status => 400 }
      end
    end
  end

  def destroy
    unimage = current_user.unimages.where(token: unimage_destroy_params[:token]).where(id: unimage_destroy_params[:id]).take
    respond_to do |format|
      if Unimage.destroy(unimage.id)
        format.json { head :ok, :status => 200 }
      else
        format.json { render json: { error: @unimage.errors.full_messages }, :status => 400 }
      end
    end
  end


  ################################ PRIVATE METHODS #############################
  private
  def unimage_create_params
    # if params[:unimage].present?
    #   if params[:unimage][:token].present?
    #     params.require(:unimage).permit(:filename, :token)
    #   elsif params[:unimage][:unpost_id].present?
    #     params.require(:unimage).permit(:filename, :unpost_id)
    #   else
    #     nil
    #   end
    # else
    #   nil
    # end
    params[:unimage].present? ? params.require(:unimage).permit(:filename, :token) : nil
  end

  def unimage_destroy_params
    params[:unimage].present? ? params.require(:unimage).permit(:id, :filename, :token) : nil
  end

  def require_correct_user
    @unimage = Unimage.find(params[:unimage][:id])
    access_denied("You are not the owner of this unimage.") unless @unimage && (current_user == @unimage.creator)
  end
end
