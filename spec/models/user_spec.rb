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

  describe "self.admin?" do
    let(:jen) { Fabricate(:user) }
    let(:joe) { Fabricate(:admin) }
    it "returns true if user's role attribute is 'admin'" do
      expect(joe.admin?).to be_true
    end
    it "returns false if user's role attribute is NOT 'admin'" do
      expect(jen.admin?).to be_false
    end
  end
end
