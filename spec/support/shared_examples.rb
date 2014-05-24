shared_examples "require_signed_in" do
  it "redirects to the root path and flashes a message"
    spec_logout_user
    verb_action
    expect(flash[:error]).to be_present
    expect(response).to redirect_to root_path
end

shared_examples "require_signed_out" do
  it "redirects to the root path and flashes a message" do
    spec_signin_user
    verb_action
    expect(flash[:error]).to be_present
    expect(response).to redirect_to home_path
  end
end
