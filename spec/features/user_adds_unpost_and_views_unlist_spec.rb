require 'spec_helper'

feature "User adds unpost and views unlist" do
  given(:jen) { Fabricate(:user) }

  scenario "of their existing account" do

    featurespec_signin_user(jen)
    visit user_unlist_path
    expect(page).to have_content "My Unlist"

    click_link "Add Unpost"
    add_unpost_via_form("doggie")

    #Automatically redirects to User's Unlist page after posting
    expect(page).to have_content "doggie"
  end
end

def add_unpost_via_form(item_name)

end
