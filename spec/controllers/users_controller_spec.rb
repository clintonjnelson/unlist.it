require 'spec_helper'

describe UsersController do
  after do
    ActionMailer::Base.deliveries.clear
    #Sidekiq::Worker.clear_all
  end

  describe "GET new" do
    context "with UN-signed-in (guest) user" do
      it "assigns the new instance of user" do
        get :new
        expect(assigns(:user)).to be_a_new User
      end
    end

    context "with an already signed in user" do
      it_behaves_like "require_signed_out" do
        let(:verb_action) { get :new }
      end
    end
  end

  describe "POST create" do
    let(:jen) { Fabricate.build(:user) }

    context "with valid input" do
      let(:params) { { user: { email: jen.email, password: jen.password, username: jen.username } } }
      before { post :create, params }

      it "assigns the input info to the user variable" do
        expect(assigns(:user)).to be_present
      end
      it "creates a new user" do
        expect(User.count).to eq(1)
      end
      it "creates a new token for the user" do
        expect(User.first.tokens).to be_present
      end
      it "signs the user in" do
        expect(session[:user_id]).to eq(1)
      end
      it "flashes the Welcome message" do
        expect(flash[:success]).to be_present
      end
      it "redirects to the user home page" do
        expect(response).to redirect_to home_path
      end

      context "confirmation email sending" do
        it "sends the email" do
          expect(ActionMailer::Base.deliveries).to_not be_empty
        end
        it "sends the email to the registering user"
        it "sends an email with a confirmation link in the body"
      end
    end
    context "with invalid input" do
      let(:params) { { user: { email: "example.com", password: jen.password, username: jen.username } } }
      before { post :create, params }

      it "assigns the input info to the user variable" do
        expect(assigns(:user)).to be_present
      end
      it "does not create a new user" do
        expect(User.count).to eq(0)
      end
      it "does not send an email" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
      it "does not sign in the user" do
        expect(session[:user_id]).to be_nil
      end
      it "flashes an error message" do
        expect(flash[:error]).to be_present
      end
      it "renders the signup page" do
        expect(response).to render_template 'new'
      end
    end
  end
end
