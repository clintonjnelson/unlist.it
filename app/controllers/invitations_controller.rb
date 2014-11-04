class InvitationsController < ApplicationController
  before_filter :require_signed_in
  before_filter :set_user,             only: [:create]
  before_filter :require_correct_user, only: [:create]

  def new
    @invitation = Invitation.new
    flash.now[:notice] = "You have #{ view_context.pluralize((current_user.invite_count.nil? ? 0 : current_user.invite_count), 'credit') } remaining."
  end

  def create
    @invitation = @user.invitations.build(invitation_params)
    credits     = InvitationCredit.new(@user)
    if credits.any? && @invitation.save
      #UnlistMailer.invitation_email(@invitation.id).deliver  #USE IN DEVELOPMENT FOR EMAILING
      UnlistMailer.delay.invitation_email(@invitation.id) #sidekiq worker
      credits.use_credit
      flash[:success]   = "Invitation Sent!"
      redirect_to new_user_invitation_path(@user)
    else @invitation.errors
      flash.now[:error] = "Oops, looks like the email is invalid - please adjust & try again."
      render 'new'
    end
  end



  private
  def invitation_params
    params.require(:invitation).permit(:recipient_email, :note)
  end

  def require_correct_user
    access_denied("You are not the correct user for this.") unless @user && (current_user == @user)
  end
end
