require 'spec_helper'

describe ResetPasswordsController do

  describe 'GET show' do
    context 'with a valid token' do
      let(:jen) { Fabricate(:user, email: 'jen@example.com', prt: '1234abcd') }
      before { get :show, { id: jen.prt } }

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
        expect(response).to redirect_to expired_password_reset_path
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
    context 'with a valid token' do
      let(:jen) { Fabricate(:user, password: 'password', prt: '1234abcd') }
      before { post :create, { token: jen.prt, password: 'new_password' } }

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
      it 'flashes a message that the users password has been changed' do
        expect(flash[:success]).to be_present
      end
      it 'renders the reset password page' do
        expect(response).to redirect_to root_path
      end
    end
    context 'with an expired token' do
      let(:jen) { Fabricate(:user, password: 'password', prt: '1234abcd', prt_created_at: 1.week.ago) }
      before { post :create, { token: jen.prt, password: 'new_password' } }

      it 'sets the user prt value to nil' do
        expect(User.first.prt).to be_nil
      end
      it 'invalidates the token timeline' do
        expect(jen.prt_created_at).to be < 2.hours.ago
      end
      it 'redirects to the expired token page' do
        expect(response).to redirect_to expired_password_reset_path
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
