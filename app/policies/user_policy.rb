class UserPolicy
  attr_reader :user
  def initialize(options={}) #could be a user or a safeguest
    @user      = options[:user     ]
    @safeguest = options[:safeguest]
  end


  def hit_notifications_on? #User Preference
    @user.present? ? (@user.preference.hit_notifications ? true : false) : nil
  end

  def messages_allowed?
    if @user.blank? && @safeguest.blank? #input error check
      nil
    elsif @user && !@user.confirmed? #|| @user.blacklisted? ...or maybe .suspended?)
      false
    elsif @safeguest && (!@safeguest.confirmed? || @safeguest.blacklisted?)
      false
    else
      true
    end
  end

  def safeguest_contact_allowed? #User Preferences
    @user.present? ? (@user.preference.safeguest_contact ? true : false) : nil
  end
end
