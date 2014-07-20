class UserPolicy
  attr_reader :user
  def initialize(options={}) #could be a user or a safeguest
    @user      = options[:user]
    @safeguest = options[:safeguest]
  end

  def messages_allowed?
    if @user && !@user.confirmed? #|| @user.blacklisted?)
      false
    elsif @safeguest && (!@safeguest.confirmed? || @safeguest.blacklisted?)
      false
    elsif @user.blank? && @safeguest.blank?
      nil
    else
      true
    end
  end
end
