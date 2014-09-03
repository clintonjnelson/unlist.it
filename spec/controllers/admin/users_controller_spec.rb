require 'spec_helper'

describe Admin::UsersController do
  let!(:settings) { Fabricate(:setting) }
  let(:joe_admin) { Fabricate(:admin) }
  let!(:jim) { Fabricate(:user) }
  let!(:jen) { Fabricate(:user) }

  describe "GET index" do
    context "with a signed-in admin" do
      before do
        spec_signin_user(joe_admin)
        get :index
      end

      it "assigns the users to the users variable for use" do
        expect(assigns(:users)).to include(jim, jen)
      end
      it "renders the admin index page" do
        expect(response).to render_template 'index'
      end
    end

    context "WITHOUT a signed-in admin" do
      it_behaves_like "require_admin" do
        let(:verb_action) { get :index }
      end
    end
  end


  describe "DELETE destroy" do

    context "with a signed_in admin" do
      before do
        spec_signin_user(joe_admin)
        delete :destroy, { id: 1 }
      end

      it "deletes the user with matching id, leaving other users" do
        expect(User.count).to eq(2)
        expect(User.first.id).to eq(2)
      end
      it "flashes a success message that user was deleted" do
        expect(flash[:success]).to include "User has been deleted"
      end
      it "redirects to the admin users index page" do
        expect(response).to redirect_to admin_users_path
      end
    end

    context "with a signed in admin bent on admin suicide/genocide (trying to delete themselves or other admin)" do
      before do
        spec_signin_user(joe_admin)
        delete :destroy, { id: joe_admin.id }
      end

      it "prevents the admin from deleting admin" do
        expect(User.count).to eq(3)
      end
      it "flashes an error that admin cannot be deleted" do
        expect(flash[:error]).to be_present
      end
      it "redirects to the admin_users path" do
        expect(response).to redirect_to admin_users_path
      end
    end

    context "WITHOUT a signed-in admin" do
      before { delete :destroy, { id: 1 } }

      it_behaves_like "require_admin" do
        let(:verb_action) { delete :index }
      end
    end

    context "with an invalid user_id" do
      before do
        spec_signin_user(joe_admin)
        delete :destroy, { id: 111 }
      end

      it "flashes an alert that there is no such user" do
        expect(flash[:alert]).to be_present
      end
      it "redirects to admin_users path" do
        expect(response).to redirect_to admin_users_path
      end
    end
  end
end
