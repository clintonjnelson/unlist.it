  source 'https://rubygems.org'
  ruby '2.0.0'
  gem 'rails' #, '4.1.1'


  gem 'bcrypt'
  gem 'bootstrap_form'
  gem 'bootstrap-sass'
  #gem 'blueimp-gallery', '2.11.0.1' #Responsive Unimages Viewer; **WIRED & WORKING IF UNCOMMENT AREAS
  gem 'carrierwave'                 #Manage Images & Uploads
  gem 'coffee-rails'
  gem 'dropzonejs-rails'
  gem 'email_validator'             #Email validations made simple
  gem 'fog'                         #AMAZON S3
  gem 'geocoder'
  gem 'haml-rails'
  gem 'jquery-rails'
  gem 'jquery-turbolinks'
  gem 'jquery-ui-rails'
  gem 'mini_magick'                 #Image control for use with Carrierwave
  gem 'paratrooper'                #deployment made simple
  gem 'sass-rails'
  gem 'sidekiq'                     #allows workers to handle queued tasks in background
  gem 'sinatra', require: nil       #For Sidekiq online monitoring
  gem 'turbolinks'
  gem 'uglifier'
  gem 'unicorn'                    #multiple instances of app for speed in production

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'faker'
  gem 'guard-rspec'
  gem 'pry'
  gem 'rspec-rails'
  gem 'spork-rails'
  gem 'sqlite3'
  gem 'thin'
end

group :development do
  gem 'spring'  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'letter_opener'
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'vcr'
end

group :production, :staging do
  gem 'newrelic_rpm'
  gem 'pg'
  gem 'rails_12factor'
  gem 'sentry-raven'
end

# Removed gems from Main
  #gem 'jquery-fileupload-rails'
  #gem 'figaro'                     #Manage ENV from YAML
  #gem 'jbuilder', '~> 2.0'
  #gem 'sdoc', '~> 0.4.0',          group: :doc
  #gem 'therubyracer',  platforms: :ruby

# Removed gems from :development, :test
  #gem 'debugger'  #recommended by Rails
  #gem 'factory_girl_rails'
  #gem 'pg'
  #gem 'pry-nav'
