require 'spec_helper'

describe InvitationCredit do

  describe "any?" do
    context "with available credits" do
      let(:jen) { Fabricate(:user, invite_count: 1) }
      it "returns true" do
        credits = InvitationCredit.new(jen)
        expect(credits.any?).to be_true
      end
    end
    context "without available credits" do
      let(:jen) { Fabricate(:user, invite_count: 0) }
      it "returns false" do
        credits = InvitationCredit.new(jen)
        expect(credits.any?).to be_false
      end
    end
  end

  describe "use_credit" do
    context "with available credits" do
      let(:jen) { Fabricate(:user, invite_count: 1) }
      it "subtracts one credit & saves" do
        InvitationCredit.new(jen).use_credit
        expect(jen.reload.invite_count).to eq(0)
      end
    end
    context "with NO credits available" do
      let(:jen) { Fabricate(:user, invite_count: 0) }
      it "does not subtract a credit" do
        InvitationCredit.new(jen).use_credit
        expect(jen.reload.invite_count).to eq(0)
      end
      it "returns false" do
        resp = InvitationCredit.new(jen).use_credit
        expect(resp).to be_false
      end
    end
  end
end
