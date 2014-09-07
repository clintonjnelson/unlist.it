class PreferencesController < ApplicationController
  before_filter :set_user,                  only: [:update]
  before_filter :format_preference_params,  only: [:update]
  before_filter :require_correct_user,      only: [:update]

  def update
    if @user.preference.update(preferences_params)
      flash[:success] = "Preferences updated."
    else
      flash[:notice]  = "Preferences could not be updated for some reason. Please notify Unlist.it admin."
    end
    redirect_to edit_user_path(@user)
  end



  private
  def preferences_params
    params.require(:preference).permit(:hit_notifications, :safeguest_contact)
  end

  def format_preference_params
    preferences_params.each { |key, value| (params[:preference][key.to_sym] = false) if ("#{value}"=="0") }
  end

  def require_correct_user
    access_denied("You are not the appropriate user.") unless current_user == @user
  end

  def set_user
    @user = User.find_by(slug: params[:user_id]) if params[:user_id]
  end
end
