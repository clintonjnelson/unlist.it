class UnlistMailer < ActionMailer::Base
  default from: "info@unlist.it"

  def invitation_email(invitation_id)
    @invitation = Invitation.find(invitation_id)
    @user       = @invitation.sender
    invitation_use_developer_email_if_in_staging
    mail(to: @invitation.recipient_email,
         from: 'info@unlist.it',
         subject: "You Have Been Exclusively Invited To Join Unlist.it")
  end

  def password_reset_email(user_id)
    @user = User.find(user_id)
    use_developer_email_if_in_staging
    mail(to: @user.email,
         from: 'info@unlist.it',
         subject: 'Link To Reset Your Unlist Password')
  end

  def password_reset_confirmation_email(user_id)
    @user = User.find(user_id)
    use_developer_email_if_in_staging
    mail(to: @user.email,
         from: 'info@unlist.it',
         subject: 'Unlist Password Changed')
  end

  def registration_confirmation_email(user_id)
    @user = User.find(user_id)
    use_developer_email_if_in_staging
    mail( to: @user.email,
          from: 'info@unlist.it',
          subject: 'Please Confirm To Complete Registration')
  end

  def safeguest_confirmation_email(safeguest_id)
    @safeguest = Safeguest.find(safeguest_id)
    use_developer_email_if_in_staging
    mail( to: @safeguest.email,
          from: 'info@unlist.it',
          subject: "Unlist.it - Confirm Your Email Is Safe")
  end

  def welcome_email(user_id)
    @user = User.find(user_id)
    use_developer_email_if_in_staging
    mail( to: @user.email,
          from: 'info@unlist.it',
          subject: 'Welcome to Unlist!')
  end

private
  def use_developer_email_if_in_staging
    @user.email  = ENV['STAGING_EMAIL'] if (@user && Rails.env.staging?)
    @guest_email = ENV['STAGING_EMAIL'] if (@guest_email && Rails.env.staging?)
  end

  def invitation_use_developer_email_if_in_staging
    @invitation.recipient_email = ENV['STAGING_EMAIL'] if (@invitation.recipient_email && Rails.env.staging?)
  end
end
