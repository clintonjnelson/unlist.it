class InvitationsController < ApplicationController
  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = current_user.invitations.build(invitation_params)
    if @invitation.save
      UnlistMailer.invitation_email(@invitation.id).deliver
      #UnlistMailer.delayed.invitation_email(@invitation.id) #sidekiq worker
      redirect_to invitation_sent_path
    else
      render 'new'
    end
  end

  private
  def invitation_params
    params.require(:invitation).permit(:recipient_email)
  end
end
