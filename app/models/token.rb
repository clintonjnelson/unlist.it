class Token < ActiveRecord::Base
  belongs_to :tokenable, polymorphic: true
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'

  before_validation :generate_token

  validates_uniqueness_of :creator, scope: [ :tokenable_id, :tokenable_type ]
  validates_presence_of   :tokenable, :token

  private
  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end
end
