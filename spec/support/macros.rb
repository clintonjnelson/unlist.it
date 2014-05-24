def spec_logout_user
  session[:user_id] = nil
end

def spec_signin_user(user = nil)
  user ||= Fabricate(:user)
  session[:user_id] = user.id
end
