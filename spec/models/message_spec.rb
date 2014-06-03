require 'spec_helper'

describe Message do
  it { should belong_to(:recipient).with_foreign_key(:recipient_id) }
  it { should belong_to(:sender   ).with_foreign_key(:sender_id   ) }

  it { should validate_presence_of(:recipient_id        ) }
  it { should validate_presence_of(:subject             ) }
  it { should validate_presence_of(:content             ) }
  it { should validate_presence_of(:messageable_type    ) }
  it { should validate_presence_of(:messageable_id      ) }

  context "conditionally validates contact_email" do
    before { self.double(:contact_email){"joe@email.com"} }
    it { should     validate_presence_of(:contact_email ) }
    it { should_not validate_presence_of(:sender_id     ) }
  end
  context "conditionally validates sender_id" do
    before { self.double(:sender_id){ 1 } }
    it { should     validate_presence_of(:sender_id     ) }
    it { should_not validate_presence_of(:contact_email ) }
  end
end
