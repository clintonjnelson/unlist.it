require 'spec_helper'

describe ForgotPasswordsController, :vcr do
  let!(:jen) { Fabricate(:user, email: 'jen@example.com') }

  describe "POST create" do
    context "with valid email provided" do
      before do
        Sidekiq::Testing.inline! do
          post :create, email: 'jen@example.com'
        end
      end
      after  { ActionMailer::Base.deliveries.clear }
      it 'sets the user associated with the email' do
        expect(assigns(:user)).to eq(jen)
      end
      it 'creates a new password reset token in the prt column of the user' do
        expect(User.first.prt).to be_present
      end
      it 'sets the prt_created_at to be the time it was created at' do
        expect(User.first.prt_created_at).to be > 5.minutes.ago
      end
      it 'sends the reset email to the users provided email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
      it 'sets the email subject to notify the user of the reset link' do
        expect(ActionMailer::Base.deliveries.first.subject).to include("Link To Reset")
      end
      it 'sends the link with token in the body of the email' do
        expect(ActionMailer::Base.deliveries.first.parts.first.body.raw_source).to include("Pick A New Password")
      end
      it 'renders a page to confirm that the password reset link has been emailed' do
        expect(response).to render_template 'confirm_password_reset_email'
      end
    end

    context "with INvalid email provided" do
      before { post :create, email: '' }

      it 'flashes a message that the email was not found' do
        expect(flash[:error]).to be_present
      end
      it 're-renders the new forgot_password template with error' do
        expect(response).to render_template 'new'
      end
      it 'does not make a token' do
        expect(jen.prt).to_not be_present
      end
      it 'does not send an email' do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end
end
