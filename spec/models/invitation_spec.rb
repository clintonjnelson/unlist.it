require 'spec_helper'

describe Invitation do
  let!(:settings) { Fabricate(:setting) }

  it { should belong_to(:sender).with_foreign_key(:user_id) }
  it { should validate_presence_of(:recipient_email) }
  it { should validate_presence_of(:user_id) }



  describe "generate_token" do
    let(:jen)    { Fabricate(:user) }
    let(:invite) { Invitation.new(recipient_email: "joe@example.com", sender: jen) }
    before { invite.save }

    it 'returns a random url-safe string' do
      expect(invite.reload.token).to be_a String
    end
    it 'returns a unique string each time it is called' do
      first_token = invite.token
      second_token = Invitation.create!(recipient_email: "jim@example.com", sender: jen).token
      expect(first_token).to_not eq(second_token)
    end
  end


  describe "set_redeemed" do
    let(:jen)    { Fabricate(:user) }
    let(:joe)    { Fabricate(:user) }
    let(:invite) { Fabricate(:invitation, recipient_email: joe.email, sender: jen) }


    context "with the intended admin user found" do
      let!(:admin) { Fabricate(:admin) }
      before do
        admin.update_column(:role, "admin")
        invite.set_redeemed
      end

      it 'sends a message to the inviter of the new user' do
        expect(Message.all.count).to eq(1)
      end
      it 'sets the message recipient to be the inviter' do
        expect(Message.first.recipient).to eq(jen)
      end
      it 'sets the message sender to be an admin' do
        expect(Message.first.sender).to eq(admin)
      end
      it 'notifies inviter of the accepted new user via email address' do
        expect(Message.first.content).to include(joe.email)
      end
      it 'sets the invitation token to nil to prevent further use' do
        expect(invite.token).to be_nil
      end
      it 'sets the -accepted- column to be true' do
        expect(invite.accepted?).to be_true
      end
    end

    context "without the admin user found" do
      before { invite.set_redeemed }

      it 'does not send a message' do
        expect(Message.all.count).to eq(0)
      end
      it 'sets the invitation token to nil to prevent further use' do
        expect(invite.token).to be_nil
      end
    end
  end
end
