require 'spec_helper'

describe User do

  it { should have_secure_password }
  it { should have_many(:tokens)   }

  it { should validate_presence_of(   :email   ) }
  it { should validate_uniqueness_of( :email   ) }
  it { should validate_presence_of(   :username) }
  it { should validate_presence_of(   :password) }
  it { should ensure_length_of(       :password).is_at_least(6) }

  it { should allow_value("email@example.com",
                          "email@example.jp",
                          "example_2@example-2.ca").for(:email) }
  it { should_not allow_value("@example.com",
                              "email@.com",
                              "email",
                              "ema*l@example.com",
                              "email@examp!e.com",
                              "email@example",
                              "email@example@com").for(:email) }
end
