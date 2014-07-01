source 'https://rubygems.org'
ruby '2.0.0'

gem 'bcrypt'
gem 'bootstrap_form'
gem 'bootstrap-sass'
gem 'carrierwave'             #Manage Images & Uploads
gem 'coffee-rails'
gem 'email_validator'         #Email validations made simple
#gem 'figaro'                 #Manage ENV from YAML
gem 'fog'                    #AMAZON S3
gem 'haml-rails'
#gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'jquery-fileupload-rails'
gem 'mini_magick'             #Image control for use with Carrierwave
#gem 'paratrooper'            #deployment made simple
gem 'rails' #, '4.1.1'
gem 'sass-rails'
#gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'sidekiq'                 #allows workers to handle queued tasks in background
gem 'sinatra', require: nil   #For Sidekiq online monitoring
gem 'turbolinks'
gem 'uglifier'
#gem 'unicorn'                #multiple instances of app for speed in production
#gem 'therubyracer',  platforms: :ruby

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  #gem 'debugger'  #recommended by Rails
  #gem 'factory_girl_rails'
  gem 'faker'
  gem 'guard-rspec'
  #gem 'pg'
  gem 'pry'
  #gem 'pry-nav'
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
  gem 'pg'
  gem 'rails_12factor'
  #gem 'sentry-raven'
end
