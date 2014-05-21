require 'spec_helper'

feature "user signs in" do
  given(:jen) { Fabricate(:user, email: 'jen@example.com') }

  scenario "existing user signs in" do
    visit root_path
    jen_signs_in(jen)
    expect(page).to have_content("Welcome, Jen!")
  end
end

def jen_signs_in(user)
  fill_in "Email",    with: 'jen@example.com'
  fill_in "Password", with: 'password'
  click_button "sign in"
end
