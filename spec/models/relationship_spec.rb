require 'spec_helper'

describe Relationship do
  let!(:setting) { Fabricate(:setting) }
  let( :jen)     { Fabricate(:user   ) }
  let( :joe)     { Fabricate(:user   ) }
  let( :jim)     { Fabricate(:user   ) }

  #it { should validate_uniqueness_of(:friend_id).scoped_to(:user_id) }
  #see test below for alternate solution

  context "for a user who has two friends" do
    let!(:friend1) { Fabricate(:relationship, user: jen, friend: joe) }
    let!(:friend2) { Fabricate(:relationship, user: jen, friend: jim) }

    it "returns each of the user's friends" do
      expect(jen.friends).to include(joe, jim)
    end
    it "does not allow a repeat of the same friend" do
      duplicate_friend = Relationship.new(user: jen, friend: joe)
      expect(duplicate_friend).to_not be_valid
    end
  end

  describe "user_cannot_follow_self custom validation" do
    it "does not allow a user to befriend themselves" do
      attempt = Relationship.new(user_id: jen.id, friend_id: jen.id)
      expect(attempt).to_not be_valid
    end
  end
end
