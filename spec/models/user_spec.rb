require 'spec_helper'

describe User do

  it { should have_secure_password }
  it { should have_many(:tokens                ) }
  it { should have_many(:unposts               ) }
  it { should have_many(:unimages              ) }
  it { should have_many(:sent_messages         ) }
  it { should have_many(:received_messages     ) }

  it { should validate_presence_of(   :email   ) }
  it { should validate_uniqueness_of( :email   ) }
  it { should validate_presence_of(   :username) }
  it { should validate_presence_of(   :password) }
  it { should ensure_length_of(       :password).is_at_least(6) }

  it { should allow_value(    "email@example.com",
                              "email@example.jp",
                              "example_2@example-2.ca").for(:email) }

  it { should_not allow_value("@example.com",
                              "email@.com",
                              "email",
                              "ema*l@example.com",
                              "email@examp!e.com",
                              "email@example",
                              "email@example@com").for(:email) }


  ############################## CALLBACKS ##############################
  describe 'set_initial_prt_created_at' do
    let(:jen) { Fabricate(:user) }
    it 'sets the initial created_at time to an expired time' do
      expect(jen.prt_created_at).to be < 2.hours.ago
    end
  end


  describe "use_new_avatar_image" do
    let(:jen) { Fabricate(:user) }
    context "for a newly uploaded image that changes the value of :avatar" do
      it "changes the use_avatar column to true to use the new image instead of gravatar"
  ##TRYING TO GET THIS TO ALlOW CHANGE, BUT CARRIERWAVE IS INTERFERING PROPERLY...
  #      jen.attributes({avatar: "1234"}).save(validate: false)
  #      expect(jen.use_avatar).to be_true
  #    end
    end
  end


  ################################ METHODS ##############################
  describe "admin?" do
    let(:jen) { Fabricate(:user) }
    let(:joe) { Fabricate(:admin) }
    it "returns true if user's role attribute is 'admin'" do
      expect(joe.admin?).to be_true
    end
    it "returns false if user's role attribute is NOT 'admin'" do
      expect(jen.admin?).to be_false
    end
  end

  describe "create_reset_token" do
    let(:jen) { Fabricate(:user) }
    before { jen.create_reset_token }

    it 'creates a reset token for the user' do
      expect(jen.prt).to be_present
    end
    it 'creates a start time for the reset tokens time limit' do
      expect(jen.prt_created_at).to be > 5.minutes.ago
    end
  end

  describe "clear_reset_token" do
    let(:jen) { Fabricate(:user, prt: '1234abcd', prt_created_at: 1.minute.ago) }
    before do
      jen.clear_reset_token
    end

    it 'sets the prt value to nil' do
      expect(jen.prt).to be_nil
    end
    it 'sets the prt_created_at value to over the valid time' do
      expect(jen.prt_created_at).to be < 2.hours.ago
    end
  end

  describe "self.secure_token" do
    it 'returns a random url-safe string' do
      expect(User.secure_token).to be_a String
    end
    it 'returns a unique string each time it is called' do
      first_token = User.secure_token
      second_token = User.secure_token
      expect(first_token).to_not eq(second_token)
    end
  end

  describe "expired_token?" do
    let!(:jen) { Fabricate(:user) }
    before { jen.create_reset_token }

    context 'for an expired token' do
      it 'returns true' do
        jen.update_column(:prt_created_at, 1.day.ago)
        expect(jen.expired_token?(2)).to be_true
      end
    end
    context 'for a still-valid token' do
      it 'returns false' do
        expect(jen.expired_token?(2)).to be_false
      end
    end
  end

  describe "use_default_avatar" do
    let(:jen) { Fabricate(:user, use_avatar: true) }
    it "resets the use_avatar column to false for use of gravatar" do
      jen.use_default_avatar
      expect(jen.use_avatar).to be_false
    end
  end
end
