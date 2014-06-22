require 'spec_helper'

describe Safeguest do

  it { should     validate_uniqueness_of(:email).case_insensitive }
  it { should     allow_value('joe@example.com', 'm@foo.jp').for( :email) }
  it { should_not allow_value('example.com', 'm@foo', 'foo').for( :email) }

  ################################# CALLBACKS ################################
  context "for creation of a new safeguest" do
    let!(:joe_guest) { Fabricate(:safeguest) }
    it "makes a new confirm_token" do
      expect(joe_guest.confirm_token).to be_present
    end
    it "makes a confirm_token_created_at time" do
      expect(joe_guest.confirm_token_created_at).to be_present
    end
  end

  ################################## METHODS ##############################
  describe "expired_token?" do
    let!(:jen_guest) { Fabricate(:safeguest) }

    context 'for an expired token' do
      it 'returns true' do
        jen_guest.update_column(:confirm_token_created_at, 1.week.ago)
          expect(jen_guest.token_expired?).to be_true
      end
    end
    context 'for a still-valid token' do
      it 'returns false' do
        expect(jen_guest.token_expired?).to be_false
      end
    end
  end

  context "reset_confirmation_token" do
    let!(:joe_guest) { Fabricate(:safeguest) }

    context "for an expired token" do
      it "makes a new confirm_token" do
        old_token = joe_guest.confirm_token
        joe_guest.reset_confirmation_token
          expect(joe_guest.reload.confirm_token).to be_present
          expect(joe_guest.reload.confirm_token).to_not eq(old_token)
      end
      it "makes a confirm_token_created_at time" do
        joe_guest.reset_confirmation_token
          expect(joe_guest.confirm_token_created_at).to be > 2.days.ago
      end
    end
  end

  context "confirm_safeguest" do
    let!(:joe_guest) { Fabricate(:safeguest) }
    before { joe_guest.confirm_safeguest }

    it "sets confirmed to be true" do
      expect(joe_guest.confirmed?).to be_true
    end
    it "sets the confirm_token to be nil" do
      expect(joe_guest.confirm_token).to be_nil
    end
    it "sets the confirm_token_created_at to equal the current time" do
      expect(joe_guest.confirm_token_created_at).to be > 1.minute.ago
    end
  end
end
