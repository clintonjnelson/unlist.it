require 'spec_helper'

describe InvitationsController do
  let!(:settings) { Fabricate(:setting) }

  describe "POST create" do
    after { ActionMailer::Base.deliveries.clear }

    context "with valid email & available invitations" do
      let!(:jen) { Fabricate(:user, invite_count: 4) }
      before do
        spec_signin_user(jen)
        Sidekiq::Testing.inline! do
          post :create, { invitation: { recipient_email: "joe@example.com", note: "hi"  },
                             user_id: jen.slug }
        end
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
      it "assigns the provided email as the Invitation recipient_email" do
        expect(Invitation.first.recipient_email).to eq("joe@example.com")
      end
      it "saves the note for use" do
        expect(Invitation.first.note).to eq("hi")
      end
      it "sends an email" do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
      it "sends an email to the recipient_email address" do
        expect(ActionMailer::Base.deliveries.first.to).to eq(["joe@example.com"])
      end
      it "flashes a success message" do
        expect(flash[:success]).to be_present
      end
      it "redirects to the invitation_sent page" do
        expect(response).to redirect_to new_user_invitation_path(jen)
      end
    end

    context "with valid email & available tokens & RESTRICTED user" do
      it "does not save the invitation"
      it "does not send the email"
      it "flashes an error"
      it "renders the new_invitation page again"
    end

    context "with INVALID email & available invitations" do
      let!(:jen) { Fabricate(:user, invite_count: 4) }
      before do
        spec_signin_user(jen)
        Sidekiq::Testing.inline! do
          post :create, { invitation: { recipient_email: "joeexample.com"  },
                             user_id: jen.slug }
        end
      end

      it "does not save the invitation" do
        expect(Invitation.all.count).to eq(0)
      end
      it "does not send an email" do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
      it "flashes an error" do
        expect(flash[:error]).to be_present
      end
      it "renders the new_invitation page again" do
        expect(response).to render_template 'new'
      end
    end

    # Formerly, would not allow invitation to be sent - restricted by limited invitations.
    context "with valid email & NO invitations" do
      let!(:jen) { Fabricate(:user, invite_count: 1) }
      before do
        spec_signin_user(jen)
        Sidekiq::Testing.inline! do
          post :create, { invitation: { recipient_email: "joe@example.com", note: "hi"  },
                             user_id: jen.slug }
        end
      end

      it "saves the invitation" do
        expect(Invitation.all.count).to eq(1)
      end
      it "saves the note for use" do
        expect(Invitation.first.note).to eq("hi")
      end
      it "sends an email" do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
      it "flashes a success" do
        expect(flash[:success]).to be_present
      end
      it "redirects to the invitation_sent page" do
        expect(response).to redirect_to new_user_invitation_path(jen)
      end
    end
  end

  context "for NON-signed in user" do
    it_behaves_like "require_signed_in" do #maybe just require_signed_in?
      let(:verb_action) { post :create, invitation: { recipient_email: "joe@example.com" },
                                           user_id: 1  }
    end
  end
end
