class Invitation < ActiveRecord::Base
  belongs_to :sender, foreign_key: 'user_id', class_name: "User"

  before_save :generate_token
  #validates



  private
  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end

end
