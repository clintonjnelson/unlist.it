require 'spec_helper'

feature "guest visits site and browses pages" do
  scenario "visits home page and browses with links" do
    visit root_path
    verify_header_links
    expect(page).to have_button "Search"
    expect(page).to have_content "There are currently"
    expect(page).to have_content "Join"

    click_link "Browse"
    expect(page).to have_content "Browse Unlist"

    #save_and_open_page
    click_link "Tour"
    expect(page).to have_content "take a tour"

    click_link "FAQ"
    expect(page).to have_content "Frequently Asked Questions"

    click_link "About"
    expect(page).to have_content "About Me & Unlist"

    click_link "Contact"
    expect(page).to have_content "Contact Us"
  end
end

def verify_header_links
  expect(page).to have_link "Unlist.co"
  expect(page).to have_link "Browse"
  expect(page).to have_link "Tour"
  expect(page).to have_link "FAQ"
  expect(page).to have_link "About"
  expect(page).to have_link "Contact"
  expect(page).to have_button "sign in"
  expect(page).to have_css("input[name='email']")
  expect(page).to have_css("input[name='password']")
end
