# Include Sidekiq Errors in SentryRaven for Staging & Production
if Rails.env.staging? || Rails.env.production?
  require 'raven/sidekiq'

  Raven.configure do |config|
    config.dsn = 'https://54f1a83f904a444baddbb9f2240ab9a1:d369e2a00fe3410ba4e59d605a499840@app.getsentry.com/29223'
  end
end

