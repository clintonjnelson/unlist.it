require 'spec_helper'

describe MessagesManager do
  let!(:settings) { Fabricate(:setting) }

  describe "send_message", :vcr do
    let( :jen          ) { Fabricate(:user,      confirmed: true      ) }
    let( :joe          ) { Fabricate(:user,      confirmed: true      ) }
    let( :jim_unconfirm) { Fabricate(:user,      confirmed: false     ) }
    let( :joe_safeguest) { Fabricate(:safeguest, confirmed: true      ) }
    let( :jim_safeguest) { Fabricate(:safeguest, confirmed: false     ) }
    let!(:jen_unlisting) { Fabricate(:unlisting,   creator: jen       ) }

    context "for a new Unlisting message" do #Context: send_message
      let(:unlisting_msg)  { MessagesManager.new(unlisting_slug: jen_unlisting.slug, parent_msg_id: nil) }

      context "with valid inputs" do  #Context: send_message/Unlisting Message
        context "by a User" do        #Context: send_message/Unlisting Message/Valid Input Context
          context "who is allowed" do #Context: send_message/Unlisting Message/Valid Input/User
            let(:msg_response) { unlisting_msg.send_message( contact_email: nil,
                                                               sender_user: joe,
                                                           reply_recipient: nil,
                                                                   content: "Got one.",
                                                                 recaptcha: false,
                                                               contact_msg: false) }
            context "to a use who has hit-notifications ON" do #Context: send_message/Unlisting Message/Valid Input/User/Allowed
              before do
                jen.preference.update_column(:hit_notifications, true)
                Sidekiq::Testing.inline!
                msg_response
              end
              after do
                ActionMailer::Base.deliveries.clear
                Sidekiq::Worker.clear_all
              end

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
              it "returns flash_success" do
                expect(unlisting_msg.flash_success).to be_present
              end
              it "sends an hit notification email the unlisting owner" do
                expect(ActionMailer::Base.deliveries        ).to_not be_empty
                expect(ActionMailer::Base.deliveries.last.to).to     eq( [jen.email] )
              end
            end

            context "to a use who has hit-notifications OFF" do #Context: send_message/Unlisting Message/Valid Input/User/Allowed
              before do
                jen.preference.update_column(:hit_notifications, false)
                Sidekiq::Testing.inline!
                msg_response
              end
              after do
                ActionMailer::Base.deliveries.clear
                Sidekiq::Worker.clear_all
              end

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
              it "returns flash_success" do
                expect(unlisting_msg.flash_success).to be_present
              end
              it "does NOT send a hit notification email to the unlisting owner" do
                expect(ActionMailer::Base.deliveries).to be_empty
              end
            end
          end




          context "who is NOT confirmed" do #Context: send_message/Unlisting Message/Valid Input/User
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
            it "returns a flash_notice" do
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



        context "by a Safeguest" do #Context: send_message/Unlisting Message/Valid Input

          context "who is allowed" do #Context: send_message/Unlisting Message/Valid Input/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: joe_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "Got one.",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }

            context "to a user who has hit-notifications ON" do #Context: send_message/Unlisting Message/Valid Input/Safeguest/Allowed
              before do
                jen.preference.update_column(:hit_notifications, true)
                Sidekiq::Testing.inline!
                msg_response
              end
              after do
                ActionMailer::Base.deliveries.clear
                Sidekiq::Worker.clear_all
              end

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
              it "returns flash_success" do
                expect(unlisting_msg.flash_success).to be_present
              end
              it "sends an hit notification email the unlisting owner" do
                expect(ActionMailer::Base.deliveries        ).to_not be_empty
                expect(ActionMailer::Base.deliveries.last.to).to     eq( [jen.email] )
              end
            end

            context "to a user who has hit-notifications OFF" do #Context: send_message/Unlisting Message/Valid Input/Safeguest/Allowed
              before do
                jen.preference.update_column(:hit_notifications, false)
                Sidekiq::Testing.inline!
                msg_response
              end
              after do
                ActionMailer::Base.deliveries.clear
                Sidekiq::Worker.clear_all
              end

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
              it "returns flash_success" do
                expect(unlisting_msg.flash_success).to be_present
              end
              it "does NOT send a hit notification email to the unlisting owner" do
                expect(ActionMailer::Base.deliveries).to be_empty
              end
            end
          end


          context "who is NOT confirmed" do #Context: send_message/Unlisting Message/Valid Input/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: jim_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "Got one.",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before do
              jen.preference.update_column(:hit_notifications, true)
              Sidekiq::Testing.inline!
              msg_response
            end
            after do
              ActionMailer::Base.deliveries.clear
              Sidekiq::Worker.clear_all
            end

            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns a flash_notice" do
              expect(unlisting_msg.flash_notice).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
            it "does NOT send a hit notification email to the unlisting owner" do
              expect(ActionMailer::Base.deliveries).to be_empty
            end
          end


          context "who is confirmed, but restricted by User who does not allow Safeguests" do #Note: send_message/Unlisting Message/Valid Input Context/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: joe_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "Got one.",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before do
              jen.preference.update_columns(safeguest_contact: false, hit_notifications: true)
              Sidekiq::Testing.inline!
              msg_response
            end
            after do
              ActionMailer::Base.deliveries.clear
              Sidekiq::Worker.clear_all
            end

            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns a flash_notice" do
              expect(unlisting_msg.flash_notice).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
            it "does NOT send a hit notification email to the unlisting owner" do
              expect(ActionMailer::Base.deliveries).to be_empty
            end
          end
          context "who is suspended" do #FUTURE FEATURE
            it "is needs the feature to be added before teting"
          end
        end


        context "by an unknown email address" do #Context: send_message/Unlisting Message/Valid Input
          let(:msg_response)   { unlisting_msg.send_message( contact_email: "dude@example.com",
                                                               sender_user: nil,
                                                           reply_recipient: nil,
                                                                   content: "Got one.",
                                                                 recaptcha: false,
                                                               contact_msg: false) }
          before do
            jen.preference.update_column(:hit_notifications, true)
            Sidekiq::Testing.inline!
            msg_response
          end
          after do
            ActionMailer::Base.deliveries.clear
            Sidekiq::Worker.clear_all
          end

          it "sends an invitation to the unknown email address" do
            expect(ActionMailer::Base.deliveries        ).to_not be_empty
            expect(ActionMailer::Base.deliveries.last.to).to     eq( ["dude@example.com"] )
          end
          it "does NOT send a hit notification email to the unlisting owner" do
            expect(ActionMailer::Base.deliveries.count).to eq(1) #invitation email, but no Hit Notification email
          end
          it "does NOT create a message" do
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



      context "with INvalid inputs" do #Context: send_message/Unlisting Message
        let(:unlisting_msg)  { MessagesManager.new(unlisting_slug: jen_unlisting.slug, parent_msg_id: nil) }


        context "by a User" do #Context: send_message/Unlisting Message/INvalid Input
          let(:msg_response) { unlisting_msg.send_message( contact_email: nil,
                                                             sender_user: joe,
                                                         reply_recipient: nil,
                                                                 content: "",
                                                               recaptcha: false,
                                                             contact_msg: false) }

          context "who is allowed" do #Context: send_message/Unlisting Message/INvalid Input/User
            before do
              jen.preference.update_column(:hit_notifications, true)
              Sidekiq::Testing.inline!
              msg_response
            end
            after do
              ActionMailer::Base.deliveries.clear
              Sidekiq::Worker.clear_all
            end
            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns an error message about the invalid input" do
              expect(unlisting_msg.error_message).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
            it "does NOT send a hit notification email to the unlisting owner" do
              expect(ActionMailer::Base.deliveries).to be_empty
            end
          end


          context "who is NOT confirmed" do #Context: send_message/Unlisting Message/INvalid Input/User
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


        context "by a Safeguest" do #Context: send_message/Unlisting Message/INvalid Input

          context "who is allowed" do #Context: send_message/Unlisting Message/INvalid Input/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: joe_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before do
              jen.preference.update_column(:hit_notifications, true)
              Sidekiq::Testing.inline!
              msg_response
            end
            after do
              ActionMailer::Base.deliveries.clear
              Sidekiq::Worker.clear_all
            end

            it "does NOT create a new message" do
              expect(Message.count).to eq(0)
            end
            it "returns the type as Unlisting" do
              expect(unlisting_msg.type).to eq("Unlisting")
            end
            it "returns the sender_type as Safeguest" do
              expect(unlisting_msg.sender_type).to eq("Safeguest")
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
            it "returns error_message" do
              expect(unlisting_msg.error_message).to be_present
            end
            it "does NOT send a hit notification email to the unlisting owner" do
              expect(ActionMailer::Base.deliveries).to be_empty
            end
          end


          context "who is NOT confirmed" do #Context: send_message/Unlisting Message/INvalid Input/Safeguest
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
            it "returns a flash_notice" do
              expect(unlisting_msg.flash_notice).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
          end


          context "who is restricted by User who does not allow Safeguests" do #Context: send_message/Unlisting Message/INvalid Input/Safeguest
            let(:msg_response)   { unlisting_msg.send_message( contact_email: joe_safeguest.email,
                                                                 sender_user: nil,
                                                             reply_recipient: nil,
                                                                     content: "",
                                                                   recaptcha: false,
                                                                 contact_msg: false) }
            before do
              jen.preference.update_columns(safeguest_contact: false, hit_notifications: true)
              Sidekiq::Testing.inline!
              msg_response
            end
            after do
              ActionMailer::Base.deliveries.clear
              Sidekiq::Worker.clear_all
            end

            it "does not create a message" do
              expect(Message.count).to eq(0)
            end
            it "returns an flash notice" do
              expect(unlisting_msg.flash_notice).to be_present
            end
            it "returns success as false" do
              expect(unlisting_msg.success).to be_false
            end
            it "does NOT send a hit notification email to the unlisting owner" do
              expect(ActionMailer::Base.deliveries).to be_empty
            end
          end

          context "who is suspended" do #FUTURE FEATURE
            it "is needs the feature to be added before teting"
          end
        end


        context "by an unknown email address" do #Context: send_message/Unlisting Message/INvalid Input
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
            expect(ActionMailer::Base.deliveries        ).to_not be_empty
            expect(ActionMailer::Base.deliveries.last.to).to     eq( ["dude@example.com"] )
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



    context "for a new Reply message" do #Context: send_message
      let(:reply_msg) { MessagesManager.new(unlisting_slug: nil, parent_msg_id: unlisting_msg.id) }

      context "by a User" do #Context: send_message/Reply Message
        let(:unlisting_msg) { Fabricate(:user_unlisting_message) }

        context "who is allowed" do #Context: Reply Message/User
          let(:msg_response) { reply_msg.send_message( contact_email: nil,
                                                         sender_user: joe,
                                                     reply_recipient: nil,
                                                             content: "Got one.",
                                                           recaptcha: false,
                                                         contact_msg: false) }
          before { msg_response }

          it "creates a new reply message" do
            expect(Message.count).to eq(2)
          end
          it "saves the reply data appropriately" do
            message = Message.last
            expect(message.content         ).to eq("Got one."                 )
            expect(message.messageable_type).to eq("Message"                  )
            expect(message.recipient_id    ).to eq(unlisting_msg.recipient.id )
            expect(message.contact_email   ).to be_nil
          end
          it "returns the type as Reply" do
            expect(reply_msg.type).to eq("Reply")
          end
          it "returns the sender_type as User" do
            expect(reply_msg.sender_type).to eq("User")
          end
          it "returns success as true" do
            expect(reply_msg.success).to be_true
          end
          it "returns flash_success" do
            expect(reply_msg.flash_success).to be_present
          end
        end


        context "who is NOT confirmed" do
          let(:msg_response) { reply_msg.send_message( contact_email: nil,
                                                         sender_user: jim_unconfirm,
                                                     reply_recipient: nil,
                                                             content: "Got one.",
                                                           recaptcha: false,
                                                         contact_msg: false) }
          before { msg_response }

          it "does not create a message" do
            expect(Message.count).to eq(1)
          end
          it "returns a flash_notice" do
            expect(reply_msg.flash_notice).to be_present
          end
          it "returns success as false" do
            expect(reply_msg.success).to be_false
          end
        end

        context "who is restricted by another User" do #FUTURE FEATURE
          it "is needs the feature to be added before teting"
        end
        context "who is suspended" do #FUTURE FEATURE
          it "is needs the feature to be added before teting"
        end
      end


      context "by a Safeguest is never allowed and" do #Context: send_message/Reply Message/Safeguest
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
          expect(reply_msg.flash_notice).to include("fishy")
        end
        it "returns success as false" do
          expect(reply_msg.success).to be_false
        end
      end
    end



    context "for a new Contact message" do #Context: send_message
      let( :contact_msg) { MessagesManager.new(unlisting_slug: nil, parent_msg_id: nil) }
      let!(:admin      ) { Fabricate(:admin) }
      before { admin.update_column(:role, 'admin') }

      context "by a User" do #Context: send_message/Contact Message
        let(:msg_response) { contact_msg.send_message( contact_email: nil,
                                                         sender_user: joe,
                                                     reply_recipient: nil,
                                                             content: "I heart Unlist.",
                                                           recaptcha: true,
                                                         contact_msg: "true") }
        before { msg_response }

        it "becomes a feedback message" do
          expect(contact_msg.type).to eq("Feedback")
        end
        it "creates a feedback message message" do
          expect(Message.count).to eq(1)
        end
        it "is of type User" do
          expect(Message.last.messageable_type).to eq("User")
        end
        it "returns a flash_success" do
          expect(contact_msg.flash_success).to be_present
        end
        it "returns success as true" do
          expect(contact_msg.success).to be_true
        end
      end

      context "by an outsider" do #Context: send_message/Contact Message
        context "with valid inputs" do
          let(:msg_response) { contact_msg.send_message( contact_email: "dude@example.com",
                                                           sender_user: nil,
                                                       reply_recipient: nil,
                                                               content: "I heart Unlist.",
                                                             recaptcha: true,
                                                           contact_msg: "true") }
          before { msg_response }

          it "creates a new contact message" do
            expect(Message.count).to eq(1)
          end
          it "saves the message data appropriately" do
            message = Message.last
            expect(message.content         ).to eq("I heart Unlist." )
            expect(message.messageable_type).to eq("User"            )
            expect(message.recipient_id    ).to eq(admin.id          )
            expect(message.contact_email   ).to eq("dude@example.com")
          end
          it "returns the type as Contact" do
            expect(contact_msg.type).to eq("Contact")
          end
          it "returns the sender_type as User" do
            expect(contact_msg.sender_type).to be_nil
          end
          it "returns success as true" do
            expect(contact_msg.success).to be_true
          end
          it "returns flash_success" do
            expect(contact_msg.flash_success).to be_present
          end
        end

        context "with INvalid input" do
          context "of recaptcha" do
            let(:msg_response) { contact_msg.send_message( contact_email: "dude@example.com",
                                                           sender_user: nil,
                                                       reply_recipient: nil,
                                                               content: "I heart Unlist.",
                                                             recaptcha: false,
                                                           contact_msg: "true") }
            before { msg_response }

            it "does not create a new contact message" do
              expect(Message.count).to eq(0)
            end
            it "returns success as false" do
              expect(contact_msg.success).to be_false
            end
            it "returns error_message as true" do
              expect(contact_msg.error_message).to be_present
            end
          end

          context "of their email address" do
            let(:msg_response) { contact_msg.send_message( contact_email: "dude",
                                                           sender_user: nil,
                                                       reply_recipient: nil,
                                                               content: "I heart Unlist.",
                                                             recaptcha: true,
                                                           contact_msg: "true") }
            before { msg_response }

            it "does not create a new contact message" do
              expect(Message.count).to eq(0)
            end
            it "returns success as false" do
              expect(contact_msg.success).to be_false
            end
            it "returns error_message as true" do
              expect(contact_msg.error_message).to be_present
            end
          end

          context "of a blank message" do
            let(:msg_response) { contact_msg.send_message( contact_email: "dude@example.com",
                                                           sender_user: nil,
                                                       reply_recipient: nil,
                                                               content: "",
                                                             recaptcha: false,
                                                           contact_msg: "true") }
            before { msg_response }

            it "does not create a new contact message" do
              expect(Message.count).to eq(0)
            end
            it "returns success as false" do
              expect(contact_msg.success).to be_false
            end
            it "returns error_message as true" do
              expect(contact_msg.error_message).to be_present
            end
          end
        end
      end
    end



    context "for a new Feedback message" do #Context: send_message
      let( :feedback_msg) { MessagesManager.new(unlisting_slug: nil, parent_msg_id: nil) }
      let!(:admin       ) { Fabricate(:admin) }
      before { admin.update_column(:role, 'admin') }

      context "by a User" do #Context: send_message/Feedback Message
        context "with Valid input" do
          let(:msg_response) { feedback_msg.send_message( contact_email: nil,
                                                            sender_user: joe,
                                                        reply_recipient: nil,
                                                                content: "I heart Unlist.",
                                                              recaptcha: false,
                                                            contact_msg: false) }
          before { msg_response }

          it "creates a new feedback message" do
            expect(Message.count).to eq(1)
          end
          it "saves the message data appropriately" do
            message = Message.last
            expect(message.content         ).to eq("I heart Unlist." )
            expect(message.messageable_type).to eq("User"            )
            expect(message.recipient_id    ).to eq(admin.id          )
            expect(message.contact_email   ).to be_nil
          end
          it "returns the type as Feedback" do
            expect(feedback_msg.type).to eq("Feedback")
          end
          it "returns the sender_type as User" do
            expect(feedback_msg.sender_type).to eq("User")
          end
          it "returns success as true" do
            expect(feedback_msg.success).to be_true
          end
          it "returns flash_success" do
            expect(feedback_msg.flash_success).to be_present
          end
        end

        context "with INvalid content input" do
          let(:msg_response) { feedback_msg.send_message( contact_email: nil,
                                                           sender_user: joe,
                                                       reply_recipient: nil,
                                                               content: "",
                                                             recaptcha: false,
                                                           contact_msg: false) }
          before { msg_response }

          it "does not create a new feedback message" do
            expect(Message.count).to eq(0)
          end
          it "returns success as false" do
            expect(feedback_msg.success).to be_false
          end
          it "returns error_message as true" do
            expect(feedback_msg.error_message).to be_present
          end
        end
      end

      context "by a non-User is never allowed and" do  #Context: send_message/Feedback Message
        let(:msg_response) { feedback_msg.send_message( contact_email: nil,
                                                          sender_user: nil,
                                                      reply_recipient: nil,
                                                              content: "I heart Unlist.",
                                                            recaptcha: false,
                                                          contact_msg: false) }
        before { msg_response }

        it "does not create a new feedback message" do
          expect(Message.count).to eq(0)
        end
        it "returns success as false" do
          expect(feedback_msg.success).to be_false
        end
        it "returns error_message as true" do
          expect(feedback_msg.error_message).to be_present
        end
      end
    end
  end
end

