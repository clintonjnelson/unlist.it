require 'spec_helper'

describe UserPolicy do
  let!(:settings) { Fabricate(:setting  ) }
  let!(:jen     ) { Fabricate(:user     ) }
  let!(:joe     ) { Fabricate(:safeguest) }

  context "for a User regarding" do
    let(:user_policy) { UserPolicy.new(user: jen) }

    context "hit_notifications_on?" do                  #context: User
      context "when hit notifications are turned ON" do #context: User/hit_notifications
        before { jen.preference.update_column(:hit_notifications, true) }

        it "returns true" do
          expect(user_policy.hit_notifications_on?).to be_true
        end
      end
      context "when hit notifications are turned OFF" do #context: User/hit_notifications
        before { jen.preference.update_column(:hit_notifications, false) }

        it "returns false" do
          expect(user_policy.hit_notifications_on?).to be_false
        end
      end
    end


    context "safeguest_contact_allowed?" do
      context "when the user allows safeguest contact" do
        before { jen.preference.update_column(:safeguest_contact, true) }

        it "returns true" do
          expect(user_policy.safeguest_contact_allowed?).to be_true
        end
      end
    end
    context "safeguest_contact_allowed?" do
      context "when the user does NOT allow safeguest contact" do
        before { jen.preference.update_column(:safeguest_contact, false) }

        it "returns false" do
          expect(user_policy.safeguest_contact_allowed?).to be_false
        end
      end
    end

    context "messages_allowed?" do
      context "whose account is confirmed" do
        before { jen.update_column(:confirmed, true) }

        it "returns true" do
          expect(user_policy.messages_allowed?).to be_true
        end
      end
      context "whose account is NOT confirmed" do
        before { jen.update_column(:confirmed, false) }

        it "returns false" do
          expect(user_policy.messages_allowed?).to be_false
        end
      end
    end
  end

  context "for a Safeguest regarding" do
    let(:user_policy) { UserPolicy.new(safeguest: joe) }

    context "messages_allowed?" do
      context "whose account is confirmed" do
        before { joe.update_column(:confirmed, true) }

        it "returns true" do
          expect(user_policy.messages_allowed?).to be_true
        end
      end
      context "whose account is NOT confirmed" do
        before { joe.update_column(:confirmed, false) }

        it "returns false" do
          expect(user_policy.messages_allowed?).to be_false
        end
      end
    end
  end

  context "for INVALID input into UserPolicy" do
    context "for a Safeguest" do
      let(:user_policy) { UserPolicy.new(safeguest: "") }

      context "hit_notifications_on?" do
        it "returns nil" do
          expect(user_policy.hit_notifications_on?).to be_nil
        end
      end
      context "messages_allowed?" do
        it "returns nil" do
          expect(user_policy.messages_allowed?).to be_nil
        end
      end
      context "safeguest_contact_allowed?" do
        it "returns nil" do
          expect(user_policy.safeguest_contact_allowed?).to be_nil
        end
      end
    end

    context "for a Safeguest" do
      let(:user_policy) { UserPolicy.new(user: "") }

      context "hit_notifications_on?" do
        it "returns nil" do
          expect(user_policy.hit_notifications_on?).to be_nil
        end
      end
      context "messages_allowed?" do
        it "returns nil" do
          expect(user_policy.messages_allowed?).to be_nil
        end
      end
      context "safeguest_contact_allowed?" do
        it "returns nil" do
          expect(user_policy.safeguest_contact_allowed?).to be_nil
        end
      end
    end

  end
end
