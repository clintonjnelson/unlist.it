class Unimage < ActiveRecord::Base
  belongs_to     :unpost
  mount_uploader :filename, UnimageUploader

  #validate       :unimages_less_than_limit_per_unpost

  validates :unpost_id, presence: true, allow_blank: true
  validates :token,     presence: true

  private
  # def unimages_less_than_limit_per_unpost
  #   if (unpost).unimages(:reload).size > 5
  #     errors.add(:base, 'Maximum Photos Per Unpost Is 6')
  #   end
  # end
end
