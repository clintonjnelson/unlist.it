require 'spec_helper'

#THIS IS FALING DUE TO THE AJAX REQUEST POPULATION OF CONDITION_SELECT

feature "User adds unpost and views unlist", { js: true } do
  given!(:item_category) { Fabricate(:category_with_condition) }
  given!(:jen) { Fabricate(:user) }


  scenario "of their existing account" do

    featurespec_signin_user(jen)
    visit user_unlist_path(jen)
    expect(page).to have_content "my unlist"

    click_link "add unpost"
    add_unpost_via_form("Civic Si")

    #Automatically redirects to User's Unlist page after posting
    expect(page).to have_content "Civic Si"
  end
end

def add_unpost_via_form(item_name)
  select "#{item_category.name}", from: "Category"
  fill_in "Title*", with: "#{item_name}"
  fill_in "Description*", with: "2000 Civic Si"
  select "#{item_category.conditions.first.level}", from: "unpost_condition_select"
  fill_in "Price", with: "5000"
  fill_in "Keyword 1*", with: "Civic"
  fill_in "Keyword 2", with: "Honda"
  fill_in "Keyword 3", with: "Si"
  fill_in "Keyword 4", with: ""
  fill_in "Website Link to a Similar Item", with: "http://www.google.com"
  find(:css, "#unpost_travel").set(true)
  select "25", from: "Distance"
  fill_in "Zipcode", with: "98052"
  click_button "Create UnPost"
end
