require 'spec_helper'

describe MessagesManager do
  let!(:settings) { Fabricate(:setting) }

  describe "send_message", :vcr do
    let( :jen          ) { Fabricate(:user, confirmed: true      ) }
    let( :joe          ) { Fabricate(:user, confirmed: true      ) }
    let( :jim_unconfirm) { Fabricate(:user, confirmed: false     ) }
    let( :joe_safeguest) { Fabricate(:safeguest, confirmed: true ) }
    let( :jim_safeguest) { Fabricate(:safeguest, confirmed: false) }
    let!(:jen_unlisting) { Fabricate(:unlisting, creator: jen    ) }

    context "for a new Unlisting message" do
      let(:unlisting_msg)  { MessagesManager.new(unlisting_slug: jen_unlisting.slug, parent_message_id: nil) }

      context "with valid inputs" do #Context: Unlisting Message

        context "by a User" do #Context: Unlisting Message/Valid Input Context
          context "who is allowed" do #Context: Unlisting Message/Valid Input/User
            let(:msg_response)   { unlisting_msg.send_message( contact_email: nil,
                                                                  sender_user: joe,
                                                              reply_recipient: nil,
                                                                      content: "Got one.",
                                                                    recaptcha: false,
                                                                  contact_msg: false) }
            before { msg_response }

            it "creates a new message" do
              expect(Message.count).to eq(1)
            end
            it "saves the data appropriately" do
              message = Message.first
              expect(message.content         ).to eq("Got one." )
              expect(message.messageable_type).to eq("Unlisting")
              expect(message.recipient_id    ).to eq( jen.id    )
              expect(message.contact_email   ).to be_nil
            end
            it "returns the type as Unlisting" do
              expect(unlisting_msg.type).to eq("Unlisting")
            end
            it "returns the sender_type as User" do
              expect(unlisting_msg.sender_type).to eq("User")
            end
            it "returns success as true" do
              expect(unlisting_msg.success).to be_true
            end
            it "returns flash_success as true" do
              expect(unlisting_msg.flash_success).to be_present
            end
          end


          context "who is NOT confirmed" do #Context: Unlisting Message/Valid Input/User
            let(:msg_response)   { unlisting_msg.send_message( contact_email: nil,
                                                                 sender_user: jim_unconfirm,
                                                             reply_recipient: nil,
                                                                     content: "Got one.",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before { msg_response }

            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns a flash_error" do
              expect(unlisting_msg.flash_notice).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
          end
          context "who is restricted by another User" do #FUTURE FEATURE
            it "is needs the feature to be added before teting"
          end
          context "who is suspended" do #FUTURE FEATURE
            it "is needs the feature to be added before teting"
          end
        end



        context "by a Safeguest" do #Context: Unlisting Message/Valid Input

          context "who is allowed" do #Context: Unlisting Message/Valid Input/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: joe_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "Got one.",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before { msg_response }

            it "creates a new message" do
              expect(Message.count).to eq(1)
            end
            it "saves the data appropriately" do
              message = Message.first
              expect(message.content         ).to eq("Got one."         )
              expect(message.messageable_type).to eq("Unlisting"        )
              expect(message.recipient_id    ).to eq(jen.id             )
              expect(message.contact_email   ).to eq(joe_safeguest.email)
            end
            it "returns the type as Unlisting" do
              expect(unlisting_msg.type).to eq("Unlisting")
            end
            it "returns the sender_type as Safeguest" do
              expect(unlisting_msg.sender_type).to eq("Safeguest")
            end
            it "returns success as true" do
              expect(unlisting_msg.success).to be_true
            end
            it "returns flash_success as true" do
              expect(unlisting_msg.flash_success).to be_present
            end
          end


          context "who is NOT confirmed" do #Context: Unlisting Message/Valid Input/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: jim_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "Got one.",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before { msg_response }

            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns a flash_error" do
              expect(unlisting_msg.flash_notice).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
          end


          context "who is confirmed, but restricted by User who does not allow Safeguests" do #Note: Valid Input Context/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: joe_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "Got one.",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before do
              jen.preference.update_column(:safeguest_contact, false)
              msg_response
            end

            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns a flash_error" do
              expect(unlisting_msg.flash_notice).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
          end
          context "who is suspended" do #FUTURE FEATURE
            it "is needs the feature to be added before teting"
          end
        end


        context "by an unknown email address" do #Context: Unlisting Message/Valid Input
          let(:msg_response)   { unlisting_msg.send_message( contact_email: "dude@example.com",
                                                               sender_user: nil,
                                                           reply_recipient: nil,
                                                                   content: "Got one.",
                                                                 recaptcha: false,
                                                               contact_msg: false) }
          before do
            Sidekiq::Testing.inline!
            msg_response
          end
          after do
            ActionMailer::Base.deliveries.clear
            Sidekiq::Worker.clear_all
          end

          it "sends an invitation to the unknown email address" do
            expect(ActionMailer::Base.deliveries).to_not be_empty
            expect(ActionMailer::Base.deliveries.first.to).to eq(["dude@example.com"])
          end
          it "does not create a message" do
            expect(Message.count).to eq(0)
          end
          it "returns a flash_notice to the user that they've been invited" do
            expect(unlisting_msg.flash_notice).to include("email")
          end
          it "returns success as false" do
            expect(unlisting_msg.success).to be_false
          end
        end
      end



      context "with INvalid inputs" do #Context: Unlisting Message
        let(:unlisting_msg)  { MessagesManager.new(unlisting_slug: jen_unlisting.slug, parent_message_id: nil) }


        context "by a User" do #Context: Unlisting Message/INvalid Input
          let(:msg_response) { unlisting_msg.send_message( contact_email: nil,
                                                             sender_user: joe,
                                                         reply_recipient: nil,
                                                                 content: "",
                                                               recaptcha: false,
                                                             contact_msg: false) }
          before { msg_response }

          context "who is allowed" do #Context: Unlisting Message/INvalid Input/User
            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns an error message about the invalid input" do
              expect(unlisting_msg.error_message).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
          end


          context "who is NOT confirmed" do #Context: Unlisting Message/INvalid Input/User
            let(:msg_response)   { unlisting_msg.send_message( contact_email: nil,
                                                                 sender_user: jim_unconfirm,
                                                             reply_recipient: nil,
                                                                     content: "",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before { msg_response }

            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns a flash notice about the UNconfirmed user" do
              expect(unlisting_msg.flash_notice).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
          end


          context "who is restricted by another User" do #FUTURE FEATURE #Context: Unlisting Message/INvalid Input/User
            it "is needs the feature to be added before teting"
          end
          context "who is suspended" do #FUTURE FEATURE #Context: Unlisting Message/INvalid Input/User
            it "is needs the feature to be added before teting"
          end
        end


        context "by a Safeguest" do #Context: Unlisting Message/INvalid Input

          context "who is allowed" #Context: Unlisting Message/INvalid Input/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: joe_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "Got one.",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before { msg_response }

            it "creates a new message" do
              expect(Message.count).to eq(1)
            end
            it "saves the data appropriately" do
              message = Message.first
              expect(message.content         ).to eq("Got one."         )
              expect(message.messageable_type).to eq("Unlisting"        )
              expect(message.recipient_id    ).to eq(jen.id             )
              expect(message.contact_email   ).to eq(joe_safeguest.email)
            end
            it "returns the type as Unlisting" do
              expect(unlisting_msg.type).to eq("Unlisting")
            end
            it "returns the sender_type as Safeguest" do
              expect(unlisting_msg.sender_type).to eq("Safeguest")
            end
            it "returns success as true" do
              expect(unlisting_msg.success).to be_true
            end
            it "returns flash_success as true" do
              expect(unlisting_msg.flash_success).to be_present
            end


          context "who is NOT confirmed" do #Context: Unlisting Message/INvalid Input/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: jim_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before { msg_response }

            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns a flash_error" do
              expect(unlisting_msg.flash_notice).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
          end


          context "who is restricted by User who does not allow Safeguests" do #Context: Unlisting Message/INvalid Input/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: joe_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before do
              jen.preference.update_column(:safeguest_contact, false)
              msg_response
            end

            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns an error message" do
              expect(unlisting_msg.error_message).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
          end

          context "who is suspended" do #FUTURE FEATURE
            it "is needs the feature to be added before teting"
          end
        end


        context "by an unknown email address" do #Context: Unlisting Message/INvalid Input
          let(:msg_response)   { unlisting_msg.send_message( contact_email: "dude@example.com",
                                                               sender_user: nil,
                                                           reply_recipient: nil,
                                                                   content: "",
                                                                 recaptcha: false,
                                                               contact_msg: false) }
          before do
            Sidekiq::Testing.inline!
            msg_response
          end
          after do
            ActionMailer::Base.deliveries.clear
            Sidekiq::Worker.clear_all
          end

          it "sends an invitation to the unknown email address" do
            expect(ActionMailer::Base.deliveries).to_not be_empty
            expect(ActionMailer::Base.deliveries.first.to).to eq(["dude@example.com"])
          end
          it "does not create a message" do
            expect(Message.count).to eq(0)
          end
          it "returns a flash_notice to the user that they've been invited" do
            expect(unlisting_msg.flash_notice).to include("email")
          end
          it "returns success as false" do
            expect(unlisting_msg.success).to be_false
          end
        end
      end
    end

    context "for a new Reply message" do
      let(:reply_msg)  { MessagesManager.new(unlisting_slug: nil, parent_message_id: unlisting_msg.id) }

      context "by a User" do
        let(:unlisting_msg) { Fabricate(:user_unlisting_message) }
        context "who is allowed"
        context "who is NOT confirmed"
        context "who is restricted by another User"
        context "who is suspended"
      end


      context "by a Safeguest is never allowed and" do
        let(:unlisting_msg) { Fabricate(:guest_unlisting_message) }
        let(:msg_response ) { reply_msg.send_message( contact_email: joe_safeguest,
                                                        sender_user: nil,
                                                    reply_recipient: nil,
                                                            content: "Got it.",
                                                          recaptcha: false,
                                                        contact_msg: false) }
        before { msg_response }

        it "does not create a reply message" do
          expect(Message.count).to eq(1)
        end
        it "returns an flash_notice to the sender that something is 'fishy' about their attempt" do
          include 'pry'; binding.pry
          expect(reply_msg.flash_notice).to include("fishy")
        end
        it "returns success as false" do
          expect(reply_msg.success).to be_false
        end
      end
    end

    context "for a new Contact message"
      context "by a User" do
        it "becomes a feedback message"
      end
      context "by an outsider" do
        context "with valid inputs"
        context "with INvalid inputs"
      end

    context "for a new Feedback message" do
      context "by a User"
      context "by a non-User" do
        it "is never allowed"
      end
    end
  end
end

