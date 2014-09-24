require 'spec_helper'

describe MessagesManager do
  let!(:settings) { Fabricate(:setting) }

  describe "send_message" do
    context "for a new Unlisting message", :vcr do
      let!(:joe)       { Fabricate(:user, confirmed: true      ) }
      let!(:unlisting) { Fabricate(:unlisting, user_id: jen.id ) }

      context "with valid inputs" do
        context "by a User" do
          context "who is allowed" do
            let!(:jen)       { Fabricate(:user, confirmed: true) }
            before do
              response = MessagesManager.new(unlisting_slug: unlisting.slug, parent_message_id: nil)
              response.send_message( contact_email: nil,
                                       sender_user: jen,
                                   reply_recipient: nil,
                                           content: "Got one.",
                                         recaptcha: false,
                                       contact_msg: false)
            end
            it "creates a new message" do
              expect(Message.count).to eq(1)
            end
            it "saves the inputs appropriately" do
              #expect(response.type).to eq("something")
            end
            it "returns the data appropriately"
          end
          context "who is NOT confirmed"
          context "who is restricted by another User"
          context "who is suspended"
        end
        context "by a Safeguest" do
          context "who is allowed"
          context "who is NOT confirmed"
          context "who is restricted by User who does not allow Safeguests"
          context "who is suspended"
        end
      end
      context "with INvalid inputs" do
        context "by a User" do
          context "who is allowed"
          context "who is NOT confirmed"
          context "who is restricted by another User"
          context "who is suspended"
        end
        context "by a Safeguest" do
          context "who is allowed"
          context "who is NOT confirmed"
          context "who is restricted by User who does not allow Safeguests"
          context "who is suspended"
        end
      end
    end

    context "for a new Reply message" do
      context "by a User" do
        context "who is allowed"
        context "who is NOT confirmed"
        context "who is restricted by another User"
        context "who is suspended"
      end
      context "by a Safeguest" do
        it "is never allowed"
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

