require 'spec_helper'

feature "User signs up" do
  scenario "guest registers and accesses the site" do
    visit signup_path

    user_fills_form_and_submits
    expect(page).to have_content "Welcome"

    user_confirms_email
    expect(page).to have_content "Thank you"
  end
end

def user_fills_form_and_submits
  fill_in "Username:",         with: "SuperJen"
  fill_in "Email Address:",    with: "jen@example.com"
  fill_in "Password:",         with: "password"
  click_button "Sign Up"
end

def user_confirms_email
  open_email "jen@example.com"
  current_email.should have_content "Confirmation"
  current_email.should have_content "SuperJen"
  current_email.should have_link "Confirm"
end
