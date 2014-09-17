class InvitationCredit #Domain Object
  attr_accessor :user
  attr_reader   :invite_count
  def initialize(user)
    @user = user
    @invite_count = user.invite_count
  end

  def any?
    @invite_count > 0
  end

  def use_credit
    if @invite_count > 0
      @invite_count = @invite_count - 1
      save
    else
      false
    end
  end

  private
  def save
    user.invite_count = @invite_count
    (@invite_count < 0) ? false : user.save
  end
end
