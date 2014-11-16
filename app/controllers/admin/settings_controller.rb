class Admin::SettingsController < AdminController

  def edit
    #@setting = Setting.first
  end

  def update
    # @setting = Setting.find(params[:id])
    # if @setting.update(setting_params)
    #   flash[:success] = "Settings Updated"
    #   redirect_to edit_admin_setting_path(current_user)
    # else
    #   flash[:error] = "Oops, there were some errors. Please fix & try again."
    #   render 'edit'
    # end
    render 'edit'
  end

  private
  def setting_params
    params.require(:setting).permit(:invites_max, :invites_ration)
  end
end
