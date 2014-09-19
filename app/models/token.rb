class Token < ActiveRecord::Base
  ###I THINK I SHOULD JUST GET RID OF THIS MODEL
  ###SEEMED LIKE A GOOD IDEA, BUT MORE COGNITIVE THAN NECESSARY
  ###ITS WHOLE INTENT WAS TO REPLACE THE TOKEN COLUMN ON A MODEL & MAKE EASY TO ADD
  ###USUALLY MORE CLEAR JUST TO ADD THE COLUMN.

  belongs_to :tokenable, polymorphic: true
  belongs_to :creator,   foreign_key: 'user_id', class_name: 'User'

  before_validation :generate_token

  validates_uniqueness_of :creator,    scope: [ :tokenable_id, :tokenable_type ]
  validates_presence_of   :tokenable, :token



  ############################# PUBLIC METHODS #################################
  def clear_token
    self.update_attribute(:token, nil)
  end

  ############################# PRIVATE METHODS ################################
  private
  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end
end
