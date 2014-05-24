class UnlistMailer < ActionMailer::Base
  default from: "info@unlist.com"

  def confirmation_email(user_id)
    @user = User.find(user_id)
    use_developer_email_if_in_staging
    mail( to: @user.email,
          from: 'info@unlist.com',
          subject: 'Please Confirm To Complete Registration')
  end

private
  def use_developer_email_if_in_staging
    @user.email = ENV['STAGING_EMAIL'] if Rails.env.staging?
  end
end
