require 'spec_helper'

feature "user signs in and out" do
  given(:jen) { Fabricate(:user, email: 'jen@example.com', username: "Jen") }

  scenario "existing user signs in" do
    visit root_path
    jen_signs_in(jen)
    expect(page).to have_content("Welcome, Jen!")

    expect(page).to have_link "My Unlist"
    expect(page).to have_link "signout"
  end
end

def jen_signs_in(user)
  fill_in "Email",    with: 'jen@example.com'
  fill_in "Password", with: 'password'
  click_button "sign in"
end
