class Setting < ActiveRecord::Base

  validates :invites_max,    numericality: { only_integer: true }
  validates :invites_ration, numericality: { only_integer: true }

end
