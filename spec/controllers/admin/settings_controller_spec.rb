require 'spec_helper'

describe Admin::SettingsController do
  let!(:settings) { Fabricate(:setting) }

  describe "GET edit" do
    let(:joe_admin) { Fabricate(:admin) }
    context "with a signed_in admin" do
      before do
        spec_signin_user(joe_admin)
        get :edit, { id: joe_admin.id }
      end

      it "loads @setting for the page display" do
        expect(assigns(:setting)).to be_present
      end
      it "renders the edit form template" do
        expect(response).to render_template 'edit'
      end
    end

    context "WITHOUT a signed_in admin" do
      it_behaves_like "require_admin" do
        let(:verb_action) { get :edit, { id: 1 } }
      end
    end
  end

  describe "PATCH update" do
    let(:joe_admin) { Fabricate(:admin) }
    context "with a signed_in admin" do
      context "with VALID input" do
        before do
          spec_signin_user(joe_admin)
          patch :update, { id: joe_admin.id, setting: { invites_max: 10, invites_ration: 10 } }
        end

        it "loads @setting for the page display" do
          expect(assigns(:setting)).to be_present
        end
        it "updates the setting accordingly" do
          expect(Setting.first.invites_ration).to eq(10)
          expect(Setting.first.invites_max   ).to eq(10)
        end
        it "flashes a success message to the admin" do
          expect(flash[:success]).to be_present
        end
        it "redirects to the edit form" do
          expect(response).to redirect_to edit_admin_setting_path(joe_admin.id)
        end
      end

      context "with INvalid input" do
        before do
          spec_signin_user(joe_admin)
          patch :update, { id: joe_admin.id, setting: { invites_max: "hi", invites_ration: "yo" } }
        end

        it "loads @setting for the page display" do
          expect(assigns(:setting)).to be_present
        end
        it "does NOT change the table values" do
          expect(Setting.first.invites_ration).to eq(4)
          expect(Setting.first.invites_max   ).to eq(4)
        end
        it "flashes an error message to the admin" do
          expect(flash[:error]).to be_present
        end
        it "redirects to the edit form" do
          expect(response).to render_template 'edit'
        end
      end
    end

    context "WITHOUT a signed_in admin" do
      it_behaves_like "require_admin" do
        let(:verb_action) { patch :update, { id: joe_admin.id, setting: { invites_max: 1, invites_ration: 1 } } }
      end
    end
  end
end
