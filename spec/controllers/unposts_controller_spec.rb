require 'spec_helper'

describe UnpostsController do
  let(:jen) { Fabricate(:user) }

  describe "GET new" do
    before do
      spec_signin_user(jen)
      get :new, user_id: jen.id
    end
    it "loads instance of the current_user as @user" do
      expect(assigns(:user)).to be_present
    end
    it "loads the instance of a new @unpost" do
      expect(assigns(:unpost)).to be_a_new Unpost
    end
    it "renders the 'new' template" do
      expect(response).to render_template 'new'
    end

    context "with UN-signedin(guest) user" do
      it_behaves_like "require_signed_in" do
        let(:verb_action) { get :new, user_id: jen.id }
      end
    end
  end

  describe "POST create" do
    context "with valid information" do
      before do
        spec_signin_user(jen)
        post :create, response_params
      end
      it "loads instance of the current_user as @user" do
        expect(assigns(:user)).to be_present
      end
      it "populates a new instance of @unpost" do
        expect(assigns(:unpost)).to be_present
      end
      it "makes a valid unpost" do
        expect(assigns(:unpost)).to be_valid
      end
      it "saves the new unpost" do
        expect(Unpost.count).to eq(1)
      end
      it "flashes a success message" do
        expect(flash[:success]).to be_present
      end
      it "redirects to the new unpost's page for viewing" do
        expect(response).to redirect_to user_unpost_path(jen.id ,Unpost.first.id)
      end
    end

    context "with invalid information" do
      before do
        spec_signin_user(jen)
        post :create, invalid_response_params
      end
      it "loads instance of the current_user as @user" do
        expect(assigns(:user)).to be_present
      end
      it "populates a new instance of @unpost" do
        expect(assigns(:unpost)).to be_present
      end
      it "makes an unvalid instance of an unpost" do
        expect(assigns(:unpost)).to_not be_valid
      end
      it "does not save the new unpost" do
        expect(Unpost.count).to eq(0)
      end
      it "loads the errors for display on the form" do
        expect(assigns(:unpost).errors.full_messages).to be_present
      end
      it "renders the new unpost page again" do
        expect(response).to render_template 'new'
      end
      it "flashes an error notifying user to correct errors" do
        expect(flash[:error]).to be_present
      end
    end

    context "with UN-signedin(guest) user" do
      it_behaves_like "require_signed_in" do
        let(:verb_action) { post :create, response_params }
      end
    end
  end

  describe "GET show" do
    let(:car_unpost) { Fabricate(:unpost) }
    before do
      spec_signin_user(jen)
      get :show, user_id: jen.id, id: car_unpost.id
    end
    it "loads instance of the current_user as @user" do
      expect(assigns(:user)).to be_present
    end
    it "loads instance of the unpost as @unpost" do
      expect(assigns(:unpost)).to be_present
    end
    it "renders the 'show' template" do
      expect(response).to render_template 'show'
    end

    context "with UN-signedin(guest) user" do
      it_behaves_like "require_signed_in" do
        let(:verb_action) { get :new, user_id: jen.id }
      end
    end
  end
end

def response_params
  params = {unpost: {category_id: 3,
                           title: "Volkswagen Bug",
                     description: "Want an awesome bug. Running. White with the number \"8\" on the side. ",
                    condition_id: 8,
                           price: 200,
                        keyword1: "volkswagen",
                        keyword2: "bug",
                        keyword3: "ocho",
                        keyword4: "",
                            link: "http://www.google.com",
                          travel: true,
                        distance: 3,
                         zipcode: 98056},
                         user_id: 1}
end

def invalid_response_params
  params = {unpost: {category_id: 3,
                           title: nil,
                     description: "Want an awesome bug. Running. White with the number \"8\" on the side. ",
                    condition_id: 8,
                           price: 200,
                        keyword1: "volkswagen",
                        keyword2: "bug",
                        keyword3: "ocho",
                        keyword4: "",
                            link: "http://www.google.com",
                          travel: true,
                        distance: 3,
                         zipcode: 98056},
                         user_id: 1}
end
