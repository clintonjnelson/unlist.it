class UserPolicy
  attr_reader :user
  def initialize(options={}) #could be a user or a safeguest
    @user      = options[:user     ]
    @safeguest = options[:safeguest]
  end


  def hit_notifications_on? #User Preference
    @user.preference.hit_notifications ? true : false
  end

  def messages_allowed?
    if @user && !@user.confirmed? #|| @user.blacklisted? ...or maybe .suspended?)
      false
    elsif @safeguest && (!@safeguest.confirmed? || @safeguest.blacklisted?)
      false
    elsif @user.blank? && @safeguest.blank?
      nil
    else
      true
    end
  end

  def safeguest_contact_allowed? #User Preferences
    @user.preference.safeguest_contact ? true : false
  end
end
