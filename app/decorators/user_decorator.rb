class UserDecorator
  include Rails.application.routes.url_helpers #enables url_for

  attr_reader :user
  # creating a new user decorator object takes a user
  def initialize(user)
    @user = user
  end

  def avatar_image_tag(size = 80, avatar_version = :thumb_avatar)
    @size = size
    @avatar_version = avatar_version
    if @user.use_avatar? && @user.avatar                #user has elected to use uploaded avatar
      avatar_image                                      #display linked image or image only
    elsif @user.use_avatar? && !@user.avatar            #no avatar image available
      @user.use_default_avatar                          #set the use_avatar back to false (use gravatar)
      gravatar_image
    else
      gravatar_image
    end
  end

  def use_avatar_checkbox
    if @user.avatar.present?
      ActionController::Base.helpers.check_box_tag("avatar",
                                                    @user.use_avatar,
                                                    @user.use_avatar,
                                                    data: { remote: true,
                                                            url: url_for( only_path: false,
                                                                          controller: "users",
                                                                          action: 'toggle_avatar',
                                                                          id: @user.id,
                                                                          currently: @user.use_avatar),
                                                            method: 'PATCH' },
                                                    class: "avatar-checkbox") #html name, html value, checkbox checked?, {Ajax Call stuff}
    end
  end

private
  def gravatar_image
    gravatar_id = Digest::MD5::hexdigest(@user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{@size}&d=mm"
    ActionController::Base.helpers.image_tag(gravatar_url, alt: @user.username, size: @size, class: "gravatar")
  end

  def avatar_image
    ActionController::Base.helpers.image_tag(@user.avatar_url(@avatar_version), size: "#{@size}", alt: @user.username)
  end
end
