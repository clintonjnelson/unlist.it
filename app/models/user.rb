class User < ActiveRecord::Base
  has_many :tokens
  has_secure_password


  validates :email,    email: true
  validates :email,    presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
end
