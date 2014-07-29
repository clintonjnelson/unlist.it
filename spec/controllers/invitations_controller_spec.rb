require 'spec_helper'

describe InvitationsController do

  describe "POST create" do
    let!(:jen)        { Fabricate(:user, invite_count: 4) }
    after { ActionMailer::Base.deliveries.clear }

    context "with valid email & available invitations" do
      before do
        spec_signin_user(jen)
        post :create, { invitation: { recipient_email: "joe@example.com"  },
                           user_id: jen.id }
      end

      it "loads the new invitation" do
        expect(assigns(:invitation)).to be_present
      end
      it "creates a new invitation" do
        expect(Invitation.all.count).to eq(1)
      end
      it "associates the invitation with the sender" do
        expect(Invitation.first.sender).to eq(jen)
      end
      it "sends an email to the recipient_email address" do
        expect(ActionMailer::Base.deliveries).to eq(1)
      end
      it "assigns the provided email as the recipient's email" do
        expect(ActionMailer::Base.deliveries.to).to eq("joe@example.com")
      end
      it "redirects to the invitation_sent page" do
        expect(response).to redirect_to invitation_sent_path
      end
    end

    context "with valid email & available tokens & RESTRICTED user" do

    end

    context "with INVALID email & available invitations" do

    end

    context "with valid email & NO invitations" do

    end
  end

  context "for NON-signed in user" do
    it_behaves_like "require_correct_user" do #maybe just require_signed_in?
      let(:verb_action) { post :create, invitation: { recipient_email: "joe@example.com" },
                                           user_id: 1  }
    end
  end
end
