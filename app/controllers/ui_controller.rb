class UiController < ApplicationController
before_filter do
  redirect_to root_path if Rails.env.production?
end

layout "application"
end
