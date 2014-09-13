require 'spec_helper'

describe UsersController, :vcr do
  let!(:settings) { Fabricate(:setting) }
  after do
    ActionMailer::Base.deliveries.clear
    Sidekiq::Worker.clear_all
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



  describe "GET new_with_invite" do

    context "with UN-signed-in (guest) user" do
      before { get :new_with_invite, { token: "1234abcd" } }
      it "assigns the new instance of user" do
        expect(assigns(:user)).to be_a_new User
      end
      it "assigns the passed token to @token" do
        expect(assigns(:token)).to eq("1234abcd")
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

    ## THESE ARE TESTS FOR WHEN INVITATION REQUIREMENTS ARE REMOVED
    # context "with valid input" do
    #   let(:params) { { user: { email: jen.email, password: jen.password, username: jen.username } } }
    #   before { post :create, params }

    #   it "assigns the input info to the user variable" do
    #     expect(assigns(:user)).to be_present
    #   end
    #   it "creates a new user" do
    #     expect(User.count).to eq(1)
    #   end
    #   it "creates a new Token object for the user token associated with the user" do
    #     expect(Token.first.tokenable_type).to eq("User")
    #     expect(Token.first.tokenable_id).to   eq(User.first.id)
    #     expect(Token.first.user_id).to        eq(User.first.id)
    #   end
    #   it "creates a new token string for the user" do
    #     expect(User.first.tokens.first.token).to be_present
    #   end
    #   it "signs the user in" do
    #     expect(session[:user_id]).to eq(1)
    #   end
    #   it "flashes the Welcome message" do
    #     expect(flash[:success]).to be_present
    #   end
    #   it "redirects to the user home page" do
    #     expect(response).to redirect_to home_path
    #   end

    #   context "confirmation email sending" do
    #     it "sends the email" do
    #       expect(ActionMailer::Base.deliveries).to_not be_empty
    #     end
    #     it "sends the email to the registering user" do
    #       expect(ActionMailer::Base.deliveries.first.to).to eq([jen.email])
    #     end
    #     it "sends an email with a confirmation link in the body" do
    #       expect(ActionMailer::Base.deliveries.first.parts.first.body.raw_source).to include("CONFIRM")
    #     end
    #   end
    # end
    # context "with invalid input" do
    #   let(:params) { { user: { email: "example.com", password: jen.password, username: jen.username } } }
    #   before { post :create, params }

    #   it "assigns the input info to the user variable" do
    #     expect(assigns(:user)).to be_present
    #   end
    #   it "does not create a new user" do
    #     expect(User.count).to eq(0)
    #   end
    #   it "does not send an email" do
    #     expect(ActionMailer::Base.deliveries).to be_empty
    #   end
    #   it "does not sign in the user" do
    #     expect(session[:user_id]).to be_nil
    #   end
    #   it "flashes an error message" do
    #     expect(flash[:error]).to be_present
    #   end
    #   it "renders the signup page" do
    #     expect(response).to render_template 'new'
    #   end
    # end

    context "with invitation token in params" do
      let(:admin) { Fabricate(:admin                    ) }
      let(:joe)   { Fabricate(:user                     ) }
      before      { admin.update_column(:role, "admin") }

      context "with valid token & input" do
        let!(:user_invite) { Fabricate(:invitation, sender: joe ) }
        let(:params)       { { user: { email: jen.email, password: jen.password, username: jen.username }, token: user_invite.token } }
        before do
          Sidekiq::Testing.inline! do
            post :create, params
          end
        end

        it "assigns the input info to the user variable" do
          expect(assigns(:user)).to be_present
        end
        it "loads the invitation by the passed token" do
          expect(assigns(:token)).to be_present
        end
        it "loads the invitation by the passed token" do
          expect(assigns(:invite)).to eq(user_invite)
        end
        it "creates a new user" do
          expect(User.count).to eq(3)
        end
        ##I think I should refactor to remove Token model.
        it "creates a new placeholder Token object for the user token associated with the user" do
          expect(Token.first.tokenable_type).to eq("User")
          expect(Token.first.tokenable_id).to   eq(User.last.id)
          expect(Token.first.user_id).to        eq(User.last.id)
        end
        it "creates a new placeholder token string for the user" do
          expect(User.last.tokens.first.token).to be_present
        end
        it "signs the user in" do
          expect(session[:user_id]).to eq(3)
        end
        it "flashes the Welcome message" do
          expect(flash[:success]).to be_present
        end
        it "redirects to the user home page" do
          expect(response).to redirect_to gettingstarted_path
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

      context "with valid token and INvalid input" do
        let!(:user_invite) { Fabricate(:invitation, sender: joe ) }
        let(:params)       { { user: { email: "example.com", password: jen.password, username: jen.username }, token: user_invite.token } }
        before do
          Sidekiq::Testing.inline! do
            post :create, params
          end
        end

        it "assigns the input info to the user variable" do
          expect(assigns(:user)).to be_present
        end
        it "does not create a new user" do
          expect(User.count).to eq(2)
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

      context "with INvalid token" do
        let!(:user_invite) { Fabricate(:invitation, sender: joe ) }
        let(:params)       { { user: { email: jen.email, password: jen.password, username: jen.username }, token: "bogus-token" } }
        before             { post :create, params }

        it "assigns the input info to the user variable" do
          expect(assigns(:user)).to be_present
        end
        it "the loads the token from the page" do
          expect(assigns(:token)).to eq('bogus-token')
        end
        it "loads the invitation by the passed token" do
          expect(assigns(:invite)).to be_nil
        end
        it "does NOT create a new user" do
          expect(User.count).to eq(2)
        end
        it "flashes the error message" do
          expect(flash[:error]).to be_present
        end
        it "redirects to the expired link path" do
          expect(response).to redirect_to expired_link_path
        end
      end
    end
  end


  describe "GET show" do
    let(:jen) { Fabricate(:user) }

    context "with the proper user" do
      before do
        spec_signin_user(jen)
        get :show, { id: jen.slug }
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
        let(:verb_action) { get :show, { id: jen.slug } }
      end
      it_behaves_like "require_signed_in" do
        let(:verb_action) { get :show, { id: jen.slug } }
      end
    end
  end


  describe "GET edit" do
    let(:jen) { Fabricate(:user) }

    context "with the proper user" do
      before do
        spec_signin_user(jen)
        get :edit, { id: jen.slug }
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
        let(:verb_action) { get :edit, { id: jen.slug } }
      end
      it_behaves_like "require_correct_user" do
        let(:verb_action) { get :edit, { id: jen.slug } }
      end
    end
  end


  describe "PATCH update" do
    let(:jen) { Fabricate(:user) }

    context "with the proper user & valid info" do
      before do
        spec_signin_user(jen)
        patch :update, { id: jen.slug, user: { email: "alternate@example.com", password: "password2" } }
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
        patch :update, { id: jen.slug, user: { email: "wrongemail", password: "password2" } }
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
        let(:verb_action) { patch :update, { id: jen.slug, user: { email: "wrongemail", password: "password2" } } }
      end
      it_behaves_like "require_correct_user" do
        let(:verb_action) { patch :update, { id: jen.slug, user: { email: "wrongemail", password: "password2" } } }
      end
    end
  end


  describe "GET confirm_with_token" do
    context "with valid token" do
      let(:jen) { Fabricate(:user) }
      let(:token) { Fabricate(:user_token, creator: jen) }
      before do
        Sidekiq::Testing.inline! do
          get :confirm_with_token, { token: token.token }
        end
      end

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
        expect(response).to redirect_to gettingstarted_path
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
          xhr :post, :toggle_avatar, id: jen.slug, currently: jen.use_avatar
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
          xhr :post, :toggle_avatar, id: jen.slug, currently: jen.use_avatar.to_s
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
        let(:verb_action) { post :toggle_avatar, id: jen.slug, currently: "false" }
      end
    end
  end

  describe "POST update_location" do
    context "correct user" do
      context "and VALID zipcode" do
        let!(:seattle) { Fabricate(:zip_location) }
        let!(:jen) { Fabricate(:user, location: seattle) }
        before do
          spec_signin_user(jen)
          xhr :post, :update_location, user_id: jen.slug, location: "98057"
        end
        it "sets the user's location to the new zipcode" do
          expect(User.first.location.zipcode).to eq(98057)
        end
        it "flashes a success message" do
          expect(flash[:success]).to be_present
        end
        it "re-renders the edit page" do
          expect(response).to be_success
        end
      end

      context "and INvalid zipcode" do
        let!(:seattle) { Fabricate(:zip_location) }
        let!(:jen) { Fabricate(:user, location: seattle) }
        before do
          spec_signin_user(jen)
          xhr :post, :update_location, user_id: jen.slug, location: "98notazip"
        end

        it "does NOT change the user's zipcode" do
          expect(User.first.location.zipcode).to eq(98164)
        end
        it "flashes an error message" do
          expect(flash[:notice]).to be_present
        end
        it "re-renders the edit page" do
          expect(response).to be_success
        end
      end

      context "and VALID city,state" do
        let!(:seattle) { Fabricate(:city_state_location) }
        let!(:jen) { Fabricate(:user, location: seattle) }
        before do
          spec_signin_user(jen)
          xhr :post, :update_location, user_id: jen.slug, location: "bellevue, wa"
        end
        it "sets the user's location to the new city & state" do
          expect(User.first.location.state).to eq('wa'      )
          expect(User.first.location.city).to  eq('bellevue')
        end
        it "flashes a success message" do
          expect(flash[:success]).to be_present
        end
        it "re-renders the edit page" do
          expect(response).to be_success
        end
      end

      context "and INvalid city,state" do
        let!(:seattle) { Fabricate(:city_state_location) }
        let!(:jen) { Fabricate(:user, location: seattle) }
        before do
          spec_signin_user(jen)
          xhr :post, :update_location, user_id: jen.slug, location: "thisisnot,astate"
        end

        it "does NOT change the user's current city & state" do
          expect(User.first.location.state).to eq('wa'      )
          expect(User.first.location.city).to  eq('seattle')
        end
        it "flashes an error message" do
          expect(flash[:notice]).to be_present
        end
        it "re-renders the edit page" do
          expect(response).to be_success
        end
      end
    end

    context "with incorrect user" do
      let!(:jen) { Fabricate(:user) }
      let!(:joe) { Fabricate(:user) }
      before do
        spec_signin_user(joe)
        xhr :post, :update_location, user_id: jen.slug, location: "thisisnot,astate"
      end
      it "renders a flash error message" do
        expect(flash[:error]).to be_present
      end
      it "re-renders the edit page" do
        expect(response).to be_success
      end
    end
  end
end
