# Duplciate of Production Environment, except servers

Rails.application.configure do
  config.cache_classes = true
  config.eager_load    = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Assets Configs
  config.serve_static_assets  = false
  config.action_controller.asset_host = Proc.new { |source|
    if source =~ /\b(.png|.jpg|.gif|.ico)\b/i
      "https://s3.amazonaws.com/unlist-assets"
    end
  }
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass
  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compress = true
  config.assets.compile  = false
  config.assets.digest   = true
  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version  = '1.0'


  # Mailer Configs
  config.action_mailer.default_url_options = { host: "unlist-it-staging.herokuapp.com" }
  config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :port           => ENV['MAILGUN_SMTP_PORT'    ],
    :address        => ENV['MAILGUN_SMTP_SERVER'  ],
    :user_name      => ENV['MAILGUN_SMTP_LOGIN'   ],
    :password       => ENV['MAILGUN_SMTP_PASSWORD'],
    :domain         => 'unlist-it-staging.heroku.com',
    :authentication => :plain }
  #ActionMailer::Base.delivery_method = :smtp

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Make sure errors get to SentryRaven
  config.action_dispatch.show_exceptions = false

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false
end
