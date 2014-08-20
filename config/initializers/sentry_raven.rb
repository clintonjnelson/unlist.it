# Include Sidekiq Errors in SentryRaven for Staging & Production
if Rails.env.staging? || Rails.env.production?
  require 'raven/sidekiq'
end
