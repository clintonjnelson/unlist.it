class Blogpost < ActiveRecord::Base
  include Sluggable #Uses :title for slug instead of :id. Callback saves to :slug
    sluggable_type   :column
    sluggable_column :title

  #Mounting
  mount_uploader    :blogpic, BlogpicUploader

  #Validations
  validates :title,   presence: true
  validates :content, presence: true
end
