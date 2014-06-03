class UnlistMailer < ActionMailer::Base
  default from: "info@unlist.co"

  def confirmation_email(user_id)
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

private
  def use_developer_email_if_in_staging
    @user.email = ENV['STAGING_EMAIL'] if Rails.env.staging?
  end
end
