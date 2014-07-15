class Safeguest < ActiveRecord::Base


  ################################## CALLBACKS #################################
  before_create :create_confirmation_token



  ################################## VALIDATIONS ###############################
  #VALID_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, uniqueness: { case_sensitive: false },
                    email: true




  #################################### METHODS #################################
  def token_expired?
    self.confirm_token_created_at.blank? ? true : self.confirm_token_created_at < 2.days.ago
  end

  def confirm_safeguest
    self.update_attributes(confirmed:                 true,
                           confirm_token:             nil,
                           confirm_token_created_at:  Time.now)
  end

  def create_confirmation_token
    self.confirm_token =            Safeguest.secure_token
    self.confirm_token_created_at = Time.now
  end

  def reset_confirmation_token
    self.update_columns(confirm_token:            Safeguest.secure_token,
                        confirm_token_created_at: Time.now)
  end

  #TODO: MAKE THIS A MODULE?
  def self.secure_token
    SecureRandom.urlsafe_base64
  end
end
