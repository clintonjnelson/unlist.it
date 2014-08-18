class Unimage < ActiveRecord::Base
  belongs_to     :unlisting
  belongs_to     :creator,  foreign_key: 'user_id', class_name: 'User'
  mount_uploader :filename, UnimageUploader


  validate  :unimages_less_than_limit_per_unlisting, on: :create
  #validates :unlisting_id, presence: true, allow_blank: true
  validates :token,     presence: true

  private
  def unimages_less_than_limit_per_unlisting
    # Note: different integer than for Unlisting, since new image not saved yet
    if Unimage.where(token: self.token).all.count > 5
      errors.add(:base, 'Maximum Photos Per Unlisting Is 6')
    end
  end
end
