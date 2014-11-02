class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: "User"

  #Validations
  validate                :user_cannot_befriend_self
  validates_uniqueness_of :friend, scope: [:user_id]


  private
  def user_cannot_befriend_self
    errors.add(:base, "No befriending yourself.") if self.user_id == self.friend_id
  end
end
