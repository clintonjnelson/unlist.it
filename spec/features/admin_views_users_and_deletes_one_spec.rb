# require 'spec_helper'

# feature "Admin views users and deletes one" do
#   given(:joe_admin) { Fabricate(:admin) }
#   given!(:jim)    { Fabricate(:user, username: "jim") }
#   given!(:jen)    { Fabricate(:user, username: 'jen') }

#   scenario "admin logs in, looks through users, and deletes one" do
#     featurespec_signin_admin(joe_admin)
#     visit admin_users_path

#     expect(page).to have_content "jim"
#     expect(page).to have_content "jen"

#     find(:xpath, "//a[@href='/admin/users/1']").click
#     expect(page).to have_content "User has been deleted"
#     expect(page).to_not have_content "jim"
#   end
# end
