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
      it "creates a new Token object for the user token associated with the user" do
        expect(Token.first.tokenable_type).to eq("User")
        expect(Token.first.tokenable_id).to eq(User.first.id)
        expect(Token.first.user_id).to eq(User.first.id)
      end
      it "creates a new token string for the user" do
        expect(User.first.tokens.first.token).to be_present
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
        it "sends the email to the registering user" do
          expect(ActionMailer::Base.deliveries.first.to).to eq([jen.email])
        end
        it "sends an email with a confirmation link in the body" do
          expect(ActionMailer::Base.deliveries.first.parts.first.body.raw_source).to include("CONFIRM")
        end
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


  describe "GET show" do
    let(:jen) { Fabricate(:user) }

    context "with the proper user" do
      before do
        spec_signin_user(jen)
        get :show, { id: jen.id }
      end
      it "assigns the current_user's user" do
        expect(assigns(:user)).to be_present
      end
      it "renders the user show page" do
        expect(response).to render_template 'show'
      end
    end

    context "with disallowed users" do
      it_behaves_like "require_signed_in" do
        let(:verb_action) { get :show, { id: jen.id } }
      end
      it_behaves_like "require_correct_user" do
        let(:verb_action) { get :show, { id: jen.id } }
      end
    end
  end


  describe "GET edit" do
    let(:jen) { Fabricate(:user) }

    context "with the proper user" do
      before do
        spec_signin_user(jen)
        get :edit, { id: jen.id }
      end
      it "assigns the current_user's user" do
        expect(assigns(:user)).to be_present
      end
      it "renders the user edit page" do
        expect(response).to render_template 'edit'
      end
    end

    context "with disallowed users" do
      it_behaves_like "require_signed_in" do
        let(:verb_action) { get :edit, { id: jen.id } }
      end
      it_behaves_like "require_correct_user" do
        let(:verb_action) { get :edit, { id: jen.id } }
      end
    end
  end


  describe "PATCH update" do
    let(:jen) { Fabricate(:user) }

    context "with the proper user & valid info" do
      before do
        spec_signin_user(jen)
        patch :update, { id: jen.id, user: { email: "alternate@example.com", password: "password2" } }
      end
      it "assigns the current_user's user" do
        expect(assigns(:user)).to be_present
      end
      it "should be valid" do
        expect(assigns(:user)).to be_valid
      end
      it "updates the users information" do
        expect(User.first.email).to eq("alternate@example.com")
        expect(User.first.authenticate("password2")).to be_true
      end
      it "flashes a success message" do
        expect(flash[:success]).to be_present
      end
      it "redirects to the user's show page" do
        expect(response).to redirect_to user_path(jen)
      end
    end

    context "with the proper user & INvalid info" do
      before do
        spec_signin_user(jen)
        patch :update, { id: jen.id, user: { email: "wrongemail", password: "password2" } }
      end
      it "assigns the current_user's user" do
        expect(assigns(:user)).to be_present
      end
      it "should NOT be valid" do
        expect(assigns(:user)).to_not be_valid
      end
      it "does NOT save the updates" do
        expect(User.first.email).to_not eq("wrongemail")
        expect(User.first.authenticate("password2")).to_not be_true
      end
      it "flashes an error message" do
        expect(flash[:error]).to be_present
      end
      it "renders the edit page again for error display" do
        expect(response).to render_template 'edit'
      end
    end

    context "with disallowed users" do
      it_behaves_like "require_signed_in" do
        let(:verb_action) { patch :update, { id: jen.id, user: { email: "wrongemail", password: "password2" } } }
      end
      it_behaves_like "require_correct_user" do
        let(:verb_action) { patch :update, { id: jen.id, user: { email: "wrongemail", password: "password2" } } }
      end
    end
  end


  describe "GET confirm_with_token" do
    context "with valid token" do
      let(:jen) { Fabricate(:user) }
      let(:token) { Fabricate(:user_token, creator: jen) }
      before { get :confirm_with_token, { token: token.token } }

      it "confirms the user by setting user's confirmed attribute to true" do
        expect(User.first).to be_confirmed
      end
      it "sends a welcome email" do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
      it "sends the welcome email to the user" do
        expect(ActionMailer::Base.deliveries.first.to).to eq([jen.email])
      end
      it "has a welcome message in the email" do
        expect(ActionMailer::Base.deliveries.first.parts.first.body.raw_source).to include("Welcome")
      end
      it "flashes a message thanking user for confirming their email" do
        expect(flash[:success]).to include "Thank you"
      end
      it "signs the user in if they aren't already signed in" do
        expect(session[:user_id]).to be_present
      end
      it "redirects the user to their home page" do
        expect(response).to redirect_to home_path
      end
    end

    context "with invalid token" do
      let(:jen) { Fabricate(:user) }
      before { get :confirm_with_token, { token: 'notAtoken' } }

      it "redirects to the invalid_address_path" do
        expect(response).to redirect_to invalid_address_path
      end
    end
  end

  describe "POST toggle_avatar_use" do
    context "with valid request & correct user" do
      context "with avatar_use toggled off" do
        let!(:jen) { Fabricate(:user) }
        before do
          spec_signin_user(jen)
          xhr :post, :toggle_avatar, id: jen.id, currently: jen.use_avatar
        end

        it "toggles the User's use_avatar boolean to on (aka: true)" do
          expect(jen.reload.use_avatar).to be_true
        end
        it "re-renders the edit page" do
          expect(response).to be_success
        end
      end

      context "with avatar_use toggled on" do
        let!(:jen) { Fabricate(:user) }
        before do
          spec_signin_user(jen)
          jen.update_columns(avatar: "1234", use_avatar: true)
          xhr :post, :toggle_avatar, id: jen.id, currently: jen.use_avatar
        end

        it "toggles the User's use_avatar boolean to off (aka: false)" do
          expect(jen.reload.use_avatar).to be_false
        end
        it "re-renders the edit page" do
          expect(response).to be_success
        end
      end
    end

    context "with incorrect user" do
      let!(:jen) { Fabricate(:user) }
      it_behaves_like "require_correct_user" do
        let(:verb_action) { post :toggle_avatar, id: jen.id, currently: "false" }
      end
    end
  end
end
