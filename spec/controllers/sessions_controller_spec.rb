require 'spec_helper'

describe SessionsController do
  let!(:settings) { Fabricate(:setting) }

  describe "POST create" do
    let(:jen) { Fabricate(:user) }

    context "with correct user information" do
      before { post :create, { email: jen.email, password: jen.password } }
      it "creates a new session for the user" do
        expect(assigns(:user)).to eq(jen)
      end
      it "flashes a 'Welcome' message to the user" do
        expect(flash[:success]).to include("Welcome")
      end
      it "redirects the user to their home page" do
        expect(response).to redirect_to home_path
      end
    end

    context "with incorrect user information" do
      it "does not create a new session" do
        post :create, {email: "wrong@example.com", password: "password" }
        expect(session[:user_id]).to be_nil
      end
      it "flashes a generic error message" do
        post :create, {email: jen.email, password: "wrong" }
        expect(flash[:error]).to be_present
      end
      it "redirects back to the sign-in(root) page" do
        post :create, {email: jen.email, password: "wrong" }
        expect(response).to redirect_to root_path
      end
    end

    context "Signed-in user tries to sign in again" do
      it "requires that the current user is signed out" do
        session[:user_id] = 1
        post :create, { email: jen.email, password: jen.password }
        expect(response).to redirect_to home_path
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "GET destroy" do
    let(:jen) { Fabricate(:user) }
    before { session[:user_id] = jen.id }

    context "signed-in user signs out" do
      before { get :destroy }
      it "signs the user out" do
        expect(session[:user_id]).to be_nil
      end
      it "redirects the user to the root path" do
        expect(response).to redirect_to root_path
      end
      it "flashed the notice message that user is now signed out" do
        expect(flash[:notice]).to include("signed out")
      end
    end

    context "UN-signed-in guest tries to sign out" do
      it "requires that the current user is signed in" do
        session[:user_id] = nil
        delete :destroy
        expect(response).to redirect_to root_path
        expect(flash[:error]).to be_present
      end
    end
  end
end
