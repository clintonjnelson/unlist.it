require 'spec_helper'

######### STILL NEED BEFORE_FILTER SPECS

describe PreferencesController do
  let!(:settings) { Fabricate(:setting) }
  let!(:jen)      { Fabricate(:user   ) }

  describe "PATCH update" do
    before { spec_signin_user(jen) }

    context "for an update to the hit_notifications " do
      context "from on to off" do
        before { patch :update, user_id: jen.slug, preference: { hit_notifications: "0", safeguest_contact: "1" }, id: jen.id }
        it "turns hit_notifications from ON to OFF" do
          expect(jen.preference.reload.hit_notifications).to be_false
        end
        it "flashes a success notice" do
          expect(flash[:success]).to be_present
        end
        it "redirects to the edit_user page" do
          expect(response).to redirect_to edit_user_path(jen)
        end
      end
      context "from off to on" do
        before do
          jen.preference.update_column(:hit_notifications, false)
          patch :update, user_id: jen.slug, preference: { hit_notifications: "1", safeguest_contact: "1" }, id: jen.id
        end
        it "turns hit_notifications on" do
          expect(jen.preference.reload.hit_notifications).to be_true
        end
        it "flashes a success notice" do
          expect(flash[:success]).to be_present
        end
        it "redirects to the edit_user page" do
          expect(response).to redirect_to edit_user_path(jen)
        end
      end
    end


    context "for an update to the safeguest_contact " do
      context "from on to off" do
        before { patch :update, user_id: jen.slug, preference: { hit_notifications: "1", safeguest_contact: "0" }, id: jen.id }
        it "turns safeguest_contact from ON to OFF" do
          expect(jen.preference.reload.safeguest_contact).to be_false
        end
        it "flashes a success notice" do
          expect(flash[:success]).to be_present
        end
        it "redirects to the edit_user page" do
          expect(response).to redirect_to edit_user_path(jen)
        end
      end
      context "from off to on" do
        before do
          jen.preference.update_column(:safeguest_contact, false)
          patch :update, user_id: jen.slug, preference: { hit_notifications: "1", safeguest_contact: "1" }, id: jen.id
        end
        it "turns safeguest_contact on" do
          expect(jen.preference.reload.safeguest_contact).to be_true
        end
        it "flashes a success notice" do
          expect(flash[:success]).to be_present
        end
        it "redirects to the edit_user page" do
          expect(response).to redirect_to edit_user_path(jen)
        end
      end
    end
  end
end
