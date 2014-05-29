class Admin::UsersController < AdminController

  def index
    @users = User.all
  end

  #ADD THE BUILT-IN RAILS CONFIRM: "ARE YOU SURE??!" TO THIS DESTROY ACTION
  def destroy
    user = User.where(id: params[:id]).take
    if user && user.admin?
      flash[:error] = "Admin cannot be deleted."
    elsif user
      user.destroy
      flash[:success] = "User has been deleted."
    else
      flash[:alert] = "There is no user with that id."
    end
    redirect_to admin_users_path
  end
end
