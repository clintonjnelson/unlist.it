require 'spec_helper'

feature "outside robot" do
  after :each do
    Capybara.app_host = nil
  end


  scenario "visits the heroku staging site" do
    Capybara.app_host = "http://localhost:3000/"
    allow(Rails.env).to receive(:production?).and_return(false)
    visit '/robots.txt'
      expect(page).to have_content("Disallow: /")
  end

  scenario "visits the heroku production site" do
    Capybara.app_host = "http://unlist-it.herokuapp.com/"
    allow(Rails.env).to receive(:production?).and_return(true)
    visit '/robots.txt'
      expect(page).to have_content("Disallow: /")
  end

  scenario "visits the www.unlist.it site" do
    Capybara.app_host = "http://www.unlist.it/"
    allow(Rails.env).to receive(:production?).and_return(true)
    visit '/robots.txt'
      expect(page).to have_content("Disallow: /admin"             )
      expect(page).to have_content("Disallow: /termsandconditions")
  end

  scenario "visits the unlist.it site" do
    Capybara.app_host = "http://unlist.it/"
    allow(Rails.env).to receive(:production?).and_return(true)
    visit '/robots.txt'
      expect(page).to have_content("Disallow: /admin"             )
      expect(page).to have_content("Disallow: /termsandconditions")
  end

  scenario "visits the unlist.it staging site" do
    Capybara.app_host = "http://unlist-it-staging.herokuapp.com/"
    allow(Rails.env).to receive(:production?).and_return(false)
    visit '/robots.txt'
      expect(page).to have_content("Disallow: /" )
  end
end
