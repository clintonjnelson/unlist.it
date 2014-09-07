class Preference < ActiveRecord::Base
  belongs_to :user

  before_create :set_initial_values


  # Callbacks
  def set_initial_values
    self.hit_notifications = true
    self.safeguest_contact = true
  end
end
