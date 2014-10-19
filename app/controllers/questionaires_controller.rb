class QuestionairesController < ApplicationController
  before_action :require_signed_in,    only: [:edit, :update, :questionaire_email]
  before_action :set_user,             only: [       :update, :questionaire_email]
  before_action :require_correct_user, only: [       :update, :questionaire_email]

  def edit
    @user         = current_user
    @questionaire = current_user.questionaire
  end

  def update
    @questionaire = current_user.questionaire
    if @questionaire.update(questionaire_params) ###FIX
      flash[:success] = "Changes saved."
      redirect_to edit_user_questionaire_path(current_user, current_user.questionaire)
    else
      flash[:error]   = "Oops, looks like some tweaks need to be made before saving. Please see below..."
      render 'edit'
    end
  end

  def questionaire_email
    if @user
      #UnlistMailer.delay.questionaire_email(@user.id)
      UnlistMailer.questionaire_email(@user.id).deliver
      flash[:success]    = "Email Sent"
      redirect_to edit_user_questionaire_path(current_user, current_user.questionaire)
    else
      flash.now[:notice] = "Email could not be sent"
      render 'edit'
    end
  end

  private
  def require_correct_user
    access_denied("You are not the appropriate user.") unless current_user == @user
  end

  def questionaire_params
    params.require(:questionaire).permit(:intuitive,
                                         :intuitive_scale,
                                         :purpose,
                                         :purpose_scale,
                                         :layout,
                                         :layout_scale,
                                         :making_unlistings,
                                         :making_unlistings_scale,
                                         :notlike1,
                                         :notlike1_scale,
                                         :keepit,
                                         :keepit_scale,
                                         :notlike2)
  end
end
