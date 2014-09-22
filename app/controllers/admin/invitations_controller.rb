class Admin::InvitationsController < AdminController

  def index
    @invitations = Invitation.all
  end

end
