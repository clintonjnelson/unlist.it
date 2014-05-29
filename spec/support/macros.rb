def spec_logout_user
  session[:user_id] = nil if session[:user_id]
end

def spec_signin_user(user = nil)
  user ||= Fabricate(:user)
  session[:user_id] = user.id
end

def featurespec_signin_user(user = nil)
  user ||= Fabricate(:user)
  visit root_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "sign in"
end

def featurespec_signin_admin(admin = nil)
  admin ||= Fabricate(:admin)
  visit root_path
  fill_in "Email",    with: admin.email
  fill_in "Password", with: admin.password
  click_button "sign in"
end
