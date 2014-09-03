require 'spec_helper'

describe ResetPasswordsController do
  let!(:settings) { Fabricate(:setting) }

  describe 'GET show' do
    context 'with a valid token' do
      let(:jen) { Fabricate(:user, email: 'jen@example.com') }
      before do
        jen.update_attributes(prt: '1234abcd', prt_created_at: 1.minute.ago)
        get :show, { id: jen.prt }
      end

      it 'sets @token to the token' do
        expect(assigns(:token)).to eq('1234abcd')
      end
      it 'renders the reset password page' do
        expect(response).to render_template 'show'
      end
    end
    context 'with an expired token' do
      let!(:jen) { Fabricate(:user, email: 'jen@example.com', prt: '1234abcd', prt_created_at: 1.day.ago) }
      before { get :show, { id: '1234abcd' } }

      it 'sets the user prt value to nil' do
        expect(User.first.prt).to be_nil
      end
      it 'invalidates the token timeline' do
        expect(jen.prt_created_at).to be < 2.hours.ago
      end
      it 'redirects to the expired token page' do
        expect(response).to redirect_to expired_link_path
      end
    end

    context 'with an invalid token' do
      let(:jen) { Fabricate(:user, email: 'jen@example.com', prt: '1234abcd') }
      before { get :show, { id: 'invalid_token' } }

      it 'redirects to the expired token page' do
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'POST create' do
    after  { ActionMailer::Base.deliveries.clear }

    context 'with a valid token' do
      let(:jen) { Fabricate(:user, password: 'password') }
      before do
        jen.update_attributes(prt: '1234abcd', prt_created_at: 1.minute.ago)
        Sidekiq::Testing.inline! do
          post :create, { token: jen.prt, password: 'new_password' }
        end
      end

      it 'sets @user to the user via the token' do
        expect(assigns(:user)).to eq(jen)
      end
      it 'changes the users password to the new provided password' do
        expect(User.first.authenticate('new_password')).to be_true
      end
      it 'clears the used prt token and time' do
        expect(User.first.prt).to be_nil
        expect(User.first.prt_created_at).to be < 2.hours.ago
      end
      it 'sends a confirmation email to the user that their password has been changed' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
      it 'sets the email subject to notify the user of the reset password' do
        expect(ActionMailer::Base.deliveries.first.subject).to include("Unlist Password Changed")
      end
      it 'sends the link with token in the body of the email' do
        expect(ActionMailer::Base.deliveries.first.parts.first.body.raw_source).to include("changed")
      end
      it 'flashes a message that the users password has been changed' do
        expect(flash[:success]).to be_present
      end
      it 'renders the root path for the user to sign in' do
        expect(response).to redirect_to root_path
      end
    end

    context 'with an expired token' do
      let!(:jen) { Fabricate(:user, password: 'password') }
      before do
        jen.update_attributes(prt: '1234abcd', prt_created_at: 1.day.ago)
        Sidekiq::Testing.inline! do
          post :create, { token: jen.prt, password: 'new_password' }
        end
      end

      it 'sets the user prt value to nil' do
        expect(User.first.prt).to be_nil
      end
      it 'invalidates the token timeline' do
        expect(jen.prt_created_at).to be < 2.hours.ago
      end
      it 'does not send a confirmation email' do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
      it 'redirects to the expired token page' do
        expect(response).to redirect_to expired_link_path
      end
    end

    context 'with an invalid token' do
      let(:jen) { Fabricate(:user, password: 'password', prt: '1234abcd') }
      before { post :create, { token: 'invalid_token', password: 'new_password' } }

      it 'redirects to the expired token page' do
        expect(response).to redirect_to root_path
      end
    end
  end
end
