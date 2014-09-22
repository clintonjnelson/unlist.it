class Admin::InvitationsController < AdminController

  def index
    @invitations = Invitation.order("lower(recipient_email)").all
  end

end
