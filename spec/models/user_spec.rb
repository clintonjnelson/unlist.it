require 'spec_helper'

describe User do
  let!(:settings) { Fabricate(:setting) }


  it { should have_secure_password }
  it { should belong_to(:location              ) }
  it { should have_many(:invitations           ) }
  it { should have_many(:tokens                ) } #polymorphic
  it { should have_many(:unlistings            ) }
  it { should have_many(:unimages              ) }
  it { should have_many(:sent_messages         ) }
  it { should have_many(:received_messages     ) }
  it { should have_one( :preference            ) }

  it { should validate_presence_of(  :email   ) }
  it { should validate_uniqueness_of(:email   ) }
  #it { should validate_presence_of(  :username) } #fails likely from before_validation
  it { should validate_presence_of(  :password) }
  it { should ensure_length_of(      :password).is_at_least(6) }

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

  describe "agrees_to_terms_and_conditions" do
    describe "validates that the terms and conditions has been agreed to by user and" do
      it "is not valid if a date is not set" do
        jen = Fabricate.build(:user, termsconditions: nil)
          expect(jen).to_not be_valid
          expect(jen.errors[:termsconditions]).to be_present
      end
      it "is valid if the date is set" do
        jen = Fabricate.build(:user, termsconditions: Time.now)
          expect(jen).to be_valid
          expect(jen.errors[:termsconditions]).to eq []
      end
    end
  end


  ############################## CALLBACKS ##############################
  describe 'set_initial_prt_created_at' do
    let(:jen) { Fabricate(:user) }
    it 'sets the initial created_at time to an expired time' do
      expect(jen.prt_created_at).to be < 2.hours.ago
    end
  end

  describe 'set_initial_preferences' do
    let!(:jen) { Fabricate(:user) }
    it 'sets the hit_notifications preference to true' do
      expect(jen.preference.hit_notifications).to be_true
    end
    it 'sets the safeguest_contact preference to true' do
      expect(jen.preference.safeguest_contact).to be_true
    end
  end

  describe 'generate_and_check_username' do
    let!(:jen) { Fabricate(:user) }
    it 'sets an initial value of the username to a format unlister######### for slugging' do
      expect(User.last.username).to include('unlister')
    end
    it 'sets the username to a total length of 20 characters' do
      expect(User.last.username.length).to eq(20)
    end
    it 'sets the slug to the username' do
      expect(User.last.slug).to eq(User.last.username)
    end
  end
  ################################ METHODS ##############################
  describe "admin?" do
    let(:jen) { Fabricate(:user)  }
    let(:joe) { Fabricate(:admin) }
    before    { joe.update_column(:role, "admin") }
    it "returns true if user's role attribute is 'admin'" do
      expect(joe.admin?).to be_true
    end
    it "returns false if user's role attribute is NOT 'admin'" do
      expect(jen.admin?).to be_false
    end
  end

  describe "invitations_avail?" do
    context "with available invitations left" do
      let(:jen) { Fabricate(:user, invite_count: 3) }
      it "returns true" do
        expect(jen.invitations_avail?).to be_true
      end
    end
    context "with NO invitations left" do
      let(:jen) { Fabricate(:user) }
      before { jen.update_column(:invite_count, 0) }
      it "returns false" do
        expect(jen.invitations_avail?).to be_false
      end
    end
  end

  describe "can_befriend?" do
    let!(:jen) { Fabricate(:user) }
    let( :joe) { Fabricate(:user) }
    let( :friend1) { Fabricate(:relationship, user: jen, friend: joe) }
    it "returns false if user is same as passed" do
      expect(jen.can_befriend?(jen)).to be_false
    end
    it "verifies passed user is not already in friends list" do
      jen.friend_relationships.create(friend: joe)
      expect(jen.can_befriend?(joe)).to be_false
    end
    it " returns true if user is not same & not already a friend" do
      expect(jen.can_befriend?(joe)).to be_true
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
