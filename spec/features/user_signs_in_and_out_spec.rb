require 'spec_helper'

feature "user signs in and out" do
  given(:jen) { Fabricate(:user, email: 'jen@example.com', username: "Jen") }

  scenario "existing user signs in" do
    visit root_path

    jen_signs_in(jen)
    links_update_for_signed_in_user
    expect(page).to have_content("Welcome, Jen!")

    jen_signs_out
    expect(page).to have_content "signed out."
  end
end

def jen_signs_in(user)
  fill_in "Email",    with: 'jen@example.com'
  fill_in "Password", with: 'password'
  click_button "sign in"
end

def links_update_for_signed_in_user
  expect(page).to have_link "my unlist"
  expect(page).to have_link "signout"
  expect(page).to have_content "#{jen.username}"
end

def jen_signs_out
  click_link "signout"
end
