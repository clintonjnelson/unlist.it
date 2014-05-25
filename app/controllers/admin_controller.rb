class AdminController < ApplicationController
  before_action :require_signed_in
  before_action :requires_admin

  private
    def requires_admin
      unless current_user && current_user.admin?
        flash[:error] = "Restricted Access: Admin Only."
        redirect_to root_path
      end
    end
end
