class UnlistMailer < ActionMailer::Base
  default from: "info@unlist.co"

  def safeguest_confirmation_email(safeguest_id)
    @safeguest = Safeguest.find(safeguest_id)
    use_developer_email_if_in_staging
    mail( to: @safeguest.email,
          from: 'info@unlist.co',
          subject: "Unlist.co - Confirm Your Email Is Safe")
  end

  def registration_confirmation_email(user_id)
    @user = User.find(user_id)
    use_developer_email_if_in_staging
    mail( to: @user.email,
          from: 'info@unlist.co',
          subject: 'Please Confirm To Complete Registration')
  end

  def welcome_email(user_id)
    @user = User.find(user_id)
    use_developer_email_if_in_staging
    mail( to: @user.email,
          from: 'info@unlist.co',
          subject: 'Welcome to Unlist!')
  end

  def password_reset_email(user_id)
    @user = User.find(user_id)
    use_developer_email_if_in_staging
    mail(to: @user.email,
         from: 'info@unlist.co',
         subject: 'Link To Reset Your Unlist Password')
  end

  def password_reset_confirmation_email(user_id)
    @user = User.find(user_id)
    use_developer_email_if_in_staging
    mail(to: @user.email,
         from: 'info@unlist.co',
         subject: 'Unlist Password Changed')
  end

private
  def use_developer_email_if_in_staging
    @user.email  = ENV['STAGING_EMAIL'] if (@user && Rails.env.staging?)
    @guest_email = ENV['STAGING_EMAIL'] if (@guest_email && Rails.env.staging?)
  end
end
