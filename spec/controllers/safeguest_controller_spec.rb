require 'spec_helper'

describe SafeguestsController do

  describe 'GET create' do
    context "with valid confirm_token" do
      let!(:joe_guest) { Fabricate(:safeguest, email: 'joe@example.com') }
      before { get :create, token: joe_guest.confirm_token }

      it "loads the safeguest for the token provided" do
        expect(assigns(:safeguest)).to be_present
      end
      it "sets confirmed to true" do
        expect(Safeguest.first.confirmed).to be_true
      end
      it "redirects to the safeguest success page" do
        expect(response).to redirect_to safeguestsuccess_path
      end
    end

    context "with INvalid confirm_token" do
      let!(:joe_guest) { Fabricate(:safeguest, email: 'joe@example.com') }
      before { get :create, token: 'invalid_token' }

      it "does NOT loads the safeguest for the email provided" do
        expect(assigns(:safeguest)).to_not be_present
      end
      it "keeps confirmed set to false" do
        expect(Safeguest.first.confirmed).to be_false
      end
      it "redirects to the expired link page" do
        expect(response).to redirect_to expired_link_path
      end
    end

    context "with EXPIRED confirm_token_created_at"do
      let!(:joe_guest) { Fabricate(:safeguest, email: 'joe@example.com') }
      before do
        joe_guest.update_attribute(:confirm_token_created_at, 1.month.ago)
        get :create, token: joe_guest.confirm_token
      end

      it "loads the safeguest for the email provided" do
        expect(assigns(:safeguest)).to be_a Safeguest
      end
      it "keeps confirmed set to false" do
        expect(Safeguest.first.confirmed).to be_false
      end
      it "redirects to the expired link page" do
        expect(response).to redirect_to expired_link_path
      end
    end
  end
end
