require 'spec_helper'
#INDEX is done - pulls messages for displaying on user interface



describe MessagesController do
  let(:jen)          { Fabricate(:user) }
  let(:jens_unpost)  { Fabricate(:unpost, creator: jen) }

  ##COULD USE THIS FOR THE TYPICAL USER CASE...
  # describe "GET new" do
  #   context "with valid information" do
  #     before { get :new }
  #     it "creates a new message instance" do
  #       expect(assigns(:message)).to be_a_new Message
  #     end
  #     it "renders the 'new' view template" do
  #       expect(response).to render_template 'new'
  #     end
  #   end
  # end

  #I THINK THIS SHOULD BE REFACTORED AS A POLICY OR SERVICE OBJECT
  describe "GET index" do
    let!(:sent_unpost_message)     { Fabricate(:user_unpost_message,  sender:        jen) }
    let!(:received_unpost_message) { Fabricate(:user_unpost_message,  recipient:     jen) }
    let!(:sent_user_message)       { Fabricate(:user_message,         sender:        jen) }
    let!(:received_user_message)   { Fabricate(:user_message,         recipient:     jen, content: "not an unpost message", messageable_type: 'User') }
    let!(:guest_message)           { Fabricate(:guest_unpost_message, recipient:     jen, contact_email: "guest@example.com") }
    let!(:unpost_reply)            { Fabricate(:message_message,      messageable:   sent_unpost_message) }
    let!(:user_reply)              { Fabricate(:message_message,      messageable:   sent_user_message) }
    before { spec_signin_user(jen) }

    context "for ALL primary sent/received messages" do
      before do
        get :index, { user_id: 1 }
      end
      it "sets @messages to all top-level messages for the user (ie: NOT replies) with newest first" do
        expect(assigns(:messages)).to eq([guest_message, received_user_message, sent_user_message, received_unpost_message, sent_unpost_message])
      end
      it "does not include responses to primary messages" do
        expect(assigns(:messages)).to_not include(unpost_reply, user_reply)
      end
      it "renders the index template" do
        expect(response).to render_template 'index'
      end
    end

    context "for messages that are 'HITS' on unposts" do
      before do
        get :index, { user_id: 1, type: 'hits' }
      end
      it "sets @messages to all top-level hits on unposts with newest first" do
        expect(assigns(:messages)).to eq([guest_message, received_unpost_message])
      end
      it "does not include sent messages or responses to primary messages" do
        expect(assigns(:messages)).to_not include([sent_unpost_message, sent_user_message, received_user_message, unpost_reply, user_reply])
      end
      it "renders the index template" do
        expect(response).to render_template 'index'
      end
    end

    context "for messages RECEIVED by the user - AKA: User's Inbox" do
      before do
        get :index, { user_id: 1, type: 'received' }
      end
      it "sets @messages to all top-level received messages for the user (ie: NOT replies)" do
        expect(assigns(:messages)).to eq([guest_message, received_user_message, received_unpost_message])
      end
      it "does not include responses to primary messages" do
        expect(assigns(:messages)).to_not include(unpost_reply, user_reply)
      end
      it "renders the index template" do
        expect(response).to render_template 'index'
      end
    end

    context "for messages SENT by the user" do
      before do
        get :index, { user_id: 1, type: 'sent' }
      end
      it "sets @messages to all top-level sent messages for the user (ie: NOT replies)" do
        expect(assigns(:messages)).to eq([sent_user_message, sent_unpost_message])
      end
      it "does not include responses to primary messages" do
        expect(assigns(:messages)).to_not include(unpost_reply, user_reply)
      end
      it "renders the index template" do
        expect(response).to render_template 'index'
      end
    end

    it_behaves_like "set_user" do
      let(:verb_action) { get :index, unpost_id: 1 }
    end
    it_behaves_like "require_signed_in" do
      let(:verb_action) { get :index, unpost_id: 1 }
    end
  end



  describe "POST create" do
    describe "message about unpost to user from guest" do
      context "with valid information" do
        context "with NEW, UN-confirmed, and valid guest email" do
          before { post :create, { unpost_id: jens_unpost.id,
                                     message: { content: "I would love to sell you mine!",
                                                contact_email: "guest@example.com",
                                                reply: false } } }
          after { ActionMailer::Base.deliveries.clear }

          it "makes a new safeguest" do
            expect(Safeguest.all.count).to eq(1)
          end
          it "saves the guest email" do
            expect(Safeguest.first.email).to eq("guest@example.com")
          end
          it "makes a new safeguest token" do
            expect(Safeguest.first.confirm_token).to be_present
          end
          it "sends an invitation for the guest to be put on Unlists safe-email list" do
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
          it "does NOT save the message" do
            expect(Message.all.count).to eq(0)
          end
          it "flashes a notice message to the guest user to check email & be added to the safe-list" do
            expect(flash[:notice]).to be_present
          end
          it "renders the unposts/show page again" do
            expect(response).to render_template 'unposts/show'
          end
        end

        context "with EXISTING, UN-confirmed guest with valid token" do
          let!(:joe_guest) { Fabricate(:safeguest, email: "guest@example.com") }
          before { post :create, { unpost_id: jens_unpost.id,
                                     message: { content: "I would love to sell you mine!",
                                                contact_email: "guest@example.com",
                                                reply: false } } }
          after { ActionMailer::Base.deliveries.clear }

          it "does NOT save the message" do
            expect(Message.all.count).to eq(0)
          end
          it "flashes a notice message to the guest user to check email & be added to the safe-list" do
            expect(flash[:notice]).to be_present
          end
          it "renders the unposts/show page again" do
            expect(response).to render_template 'unposts/show'
          end
        end

        context "with EXISTING, UN-confirmed guest with EXPIRED token" do
          let!(:joe_guest) { Fabricate(:safeguest, email: "guest@example.com") }
          before do
            joe_guest.update_column(:confirm_token_created_at, 1.month.ago)
            post :create, { unpost_id: jens_unpost.id,
                            message: { content: "I would love to sell you mine!",
                                       contact_email: "guest@example.com",
                                       reply: false } }
          end
          after { ActionMailer::Base.deliveries.clear }

          it "makes a new valid token" do
            expect(Safeguest.first.token_expired?).to be_false
          end
          it "sends another confirmation email with link to the guest" do
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
          it "does NOT save the message" do
            expect(Message.all.count).to eq(0)
          end
          it "flashes a notice message to the guest user to check email & be added to the safe-list" do
            expect(flash[:notice]).to be_present
          end
          it "renders the unposts/show page again" do
            expect(response).to render_template 'unposts/show'
          end
        end

        context "with EXISTING BLACKLISTED safeguest" do
          let!(:joe_guest) { Fabricate(:safeguest, email: "guest@example.com",
                                                   confirmed: true,
                                                   blacklisted: true) }
          before { post :create, { unpost_id: jens_unpost.id,
                            message: { content: "I would love to sell you mine!",
                                       contact_email: "guest@example.com",
                                       reply: false } } }
          after { ActionMailer::Base.deliveries.clear }

          it "does NOT save the message" do
            expect(Message.all.count).to eq(0)
          end
          it "flashes a notice message to the safeguest user that their account is suspended" do
            expect(flash[:notice]).to be_present
          end
          it "renders the unposts/show page again" do
            expect(response).to render_template 'unposts/show'
          end
        end

        context "with EXISTING CONFIRMED safeguest" do
          let!(:joe_guest) { Fabricate(:safeguest, email: "guest@example.com", confirmed: true) }
          before { post :create, { unpost_id: jens_unpost.id,
                                     message: { content: "I would love to sell you mine!",
                                                contact_email: "guest@example.com",
                                                reply: false } } }

          it "sets the recipient to the owner/creator of the unpost" do
            expect(Message.first.recipient).to eq(jen)
          end
          it "sets the subject to 'RE: ' + the title of the unpost" do
            expect(Message.first.subject).to eq("RE: #{jens_unpost.title}")
          end
          it "sets the messageable_type to 'Unpost'" do
            expect(Message.first.messageable_type).to eq('Unpost')
          end
          it "sets the messageable_id to the id of the unpost" do
            expect(Message.first.messageable_id).to eq(jens_unpost.id)
          end
          it "creates a new message" do
            expect(Message.count).to eq(1)
          end
          it "flashes a success message to the guest user" do
            expect(flash[:success]).to be_present
          end
        end
      end

      context "with INVALID information" do
        context "with existng confirmed safeguest" do
          let!(:joe_guest) { Fabricate(:safeguest, email: "guest@example.com", confirmed: true) }
          before { post :create, { unpost_id: jens_unpost.id,
                                     message: { content: "",
                                                contact_email: "guest@example.com",
                                                reply: false } } }

          it "does NOT create a new message" do
            expect(Message.count).to eq(0)
          end
          it "flashes an error message to the safeguest user" do
            expect(flash[:error]).to be_present
          end
          it "renders the errors on the prior page" do
            expect(response).to render_template 'unposts/show'
          end
        end

        context "for an INvalid email address" do
          before { post :create, { unpost_id: jens_unpost.id,
                                     message: { content: "I would like to sell you one!",
                                                contact_email: "example.com",
                                                reply: false } } }

          it "does NOT create a new message" do
            expect(Message.count).to eq(0)
          end
          it "flashes an error message to the safeguest user" do
            expect(flash[:error]).to be_present
          end
          it "renders the errors on the prior page" do
            expect(response).to render_template 'unposts/show'
          end
        end
      end
    end


    describe "Unpost message from another user" do
      context "with valid information who is confirmed" do
        before do
          spec_signin_user(jen)
          jen.update_attribute(:confirmed, true)
          post :create, { unpost_id: jens_unpost.id,
                          message: { content: "I would love to sell you mine!",
                                     contact_email: nil,
                                     reply: false } }
        end

        it "sets the recipient to the owner/creator of the unpost" do
          expect(Message.first.recipient).to eq(jen)
        end
        it "sets the subject to 'RE: ' + the title of the unpost" do
          expect(Message.first.subject).to eq("RE: #{jens_unpost.title}")
        end
        it "sets the sender to the user who sent the message" do
          expect(Message.first.sender).to eq(jen)
        end
        it "sets the messageable_type to 'unpost'" do
          expect(Message.first.messageable_type).to eq('Unpost')
        end
        it "sets the messageable_id to the id of the unpost" do
          expect(Message.first.messageable_id).to eq(jens_unpost.id)
        end
        it "creates a new message" do
          expect(Message.count).to eq(1)
        end
        it "flashes a success message to the guest user" do
          expect(flash[:success]).to be_present
        end
        it "redirects to the unpost page" do
          expect(response).to redirect_to unpost_path(jens_unpost)
        end
      end

      context "with INvalid information who is confirmed" do
        before do
          spec_signin_user(jen)
          post :create, { unpost_id: jens_unpost.id,
                            message: { content: nil,
                                       contact_email: nil,
                                       reply: false } }
        end

        it "does NOT create a new message" do
          expect(Message.count).to eq(0)
        end
        it "flashes an error message to the messaging user" do
          expect(flash[:notice]).to be_present
        end
        it "renders the prior page for error fixing" do
          expect(response).to render_template 'unposts/show'
        end
      end

      context "who is NOT confirmed" do
        before do
          spec_signin_user(jen)
          jen.update_attribute(:confirmed, false)
          post :create, { unpost_id: jens_unpost.id,
                            message: { content: "I would love to sell you mine!",
                                     contact_email: nil,
                                     reply: false } }
        end
        it "does NOT create a new message" do
          expect(Message.count).to eq(0)
        end
        it "flashes a notice to the user" do
          expect(flash[:notice]).to be_present
        end
        it "renders the prior page for use by the user after the confirm themeslves" do
          expect(response).to render_template 'unposts/show'
        end
      end
    end

    describe "Message-message (aka: reply) from a user" do
      let!(:unpost)        { Fabricate(:unpost) }
      let(:parent_message) { Fabricate(:user_unpost_message, recipient: jen) }
      context "with valid information" do
        before do
          spec_signin_user(jen)
          jen.update_attributes(confirmed: true)
          post :create, { user_id: jen.id,
                          parent_msg: parent_message.id,
                          message: { content: "I would love to buy it! Let's meet at Starbucks." } }
        end

        it "finds the parent message" do
          expect(assigns(:parent_message)).to be_present
        end
        it "does not find an unpost" do
          expect(assigns(:unpost)).to_not be_present
        end
        it "creates a new reply message" do
          expect(Message.all.count).to eq(2)
        end
        it "sets the recipient for the message" do
          expect(Message.last.recipient).to eq(parent_message.sender)
        end
        it "sets the subject to 'RE: ' + the title of the message series" do
          expect(Message.last.subject).to eq("#{parent_message.subject}")
        end
        it "sets the sender to the user who sent the message" do
          expect(Message.last.sender).to eq(jen)
        end
        it "sets the messageable_type to 'message'" do
          expect(Message.last.messageable_type).to eq('Message')
        end
        it "sets the messageable_id to the id of the Message" do
          expect(Message.last.messageable_id).to eq(parent_message.id)
        end
        it "flashes a success message to the guest user" do
          expect(flash[:success]).to be_present
        end

        #### JS RESPONSE VERSION FOR REPLIES
        context "for a parent message on an Unpost" do
          it "redirects to the message show page" do
            expect(response).to redirect_to unpost
          end
        end

        context "for a parent message to a User" do
          it "redirects to the message show page"
            #expect(response).to redirect_to user_message_path(jen, parent_message.id)
        end
      end
    end

    # describe "messages to user OR admin from user" do
    #   before do
    #     spec_signin_user(jen)
    #     post :create, { user_id: jen.id,
    #                     #sender_id: first_message.id,
    #                     message: { content: "I would love to buy it! Let's meet at Starbucks.",
    #                                contact_email: nil,
    #                                reply: true } }
    #   end
    #   describe "first message about the unpost" do
    #     context "with valid information" do
    #       it "creates a new message"
    #       it "indicates it is the primary/parent message"
    #     end
    #   end
    #   describe "followup message about the unpost" do
    #     context "with invalid information" do
    #       it "creates a new message"
    #       it "is NOT the parent message"
    #       it "is referenced to the original message"
    #     end
    #   end
    # end
  end
end
