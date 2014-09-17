Recaptcha.configure do |config|
  if Rails.env.staging? || Rails.env.production?
    config.public_key  = ENV['RECAPTCHA_PUBLIC_KEY' ]
    config.private_key = ENV['RECAPTCHA_PRIVATE_KEY']
    #config.use_ssl_by_default
    #config.proxy = 'http://myprozy.com.au:8080'
  else
    config.public_key  = '12345'
    config.private_key = '67890'
  end
end
