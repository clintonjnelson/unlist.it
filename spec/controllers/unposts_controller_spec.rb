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
    it "loads the instance of @unimages for file attachments" do
      expect(:unimages).to be_present
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
        post :create, create_params
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
        post :create, invalid_create_params
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
        let(:verb_action) { post :create, create_params }
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

  describe "PATCH update" do
    let!(:car_unpost) { Fabricate(:unpost, creator: jen) }
    before { spec_signin_user(jen) }

    context "for the correct user" do
      context "with valid updates" do
        before { patch :update, update_params }

        it "loads instance of the current_user as @user" do
          expect(assigns(:user)).to be_present
        end
        it "loads instance of the unpost as @unpost" do
          expect(assigns(:unpost)).to be_present
        end
        it "flashes a success message" do
          expect(flash[:success]).to be_present
        end
        it "renders the 'show' template" do
          expect(response).to redirect_to user_unpost_path(jen.id, car_unpost.id)
        end
      end

      context "with invalid updates" do
        before { patch :update, invalid_update_params }

        it "loads instance of the current_user as @user" do
          expect(assigns(:user)).to be_present
        end
        it "loads instance of the unpost as @unpost" do
          expect(assigns(:unpost)).to be_present
        end
        it "flashes a success message" do
          expect(flash[:error]).to be_present
        end
        it "renders the 'show' template" do
          expect(response).to render_template 'edit'
        end
      end
    end

    context "with UN-signedin(guest) user" do
      it_behaves_like "require_signed_in" do
        let(:verb_action) { patch :update, update_params }
      end
      it_behaves_like "require_correct_user" do
        let(:verb_action) { patch :update, update_params }
      end
    end
  end



  describe "GET index_by_category" do
    let(:car_unpost) { Fabricate(:unpost) }
    before do
      post :index_by_category, { category_id: car_unpost.category.id }
    end
    it "loads @categories with all categories" do
      expect(assigns(:categories)).to be_present
    end
    it "loads @unposts with unposts for the selected category" do
      expect(assigns(:unposts)).to eq([car_unpost])
    end
    it "renders the 'pages/browse' template" do
      expect(response).to render_template 'pages/browse'
    end
  end



  describe "GET index" do
    let!(:car_unpost) { Fabricate(:unpost, creator: jen, inactive: true) }
    let!(:van_unpost) { Fabricate(:unpost, creator: jen) }
    let!(:hat_unpost) { Fabricate(:unpost) }
    before do
      spec_signin_user(jen)
      get :index
    end

    it "loads the unposts variable with the un-deleted unpost" do
      expect(assigns(:unposts)).to include(van_unpost)
    end
    it "does NOT load the inactive unpost" do
      expect(assigns(:unposts)).to_not include(car_unpost)
    end
    it "does NOT load the unpost by another user" do
      expect(assigns(:unposts)).to_not include(hat_unpost)
    end
    it "renders the 'pages/browse' template" do
      expect(response).to render_template 'index'
    end
  end



  describe "DELETE destroy" do
    context "with the creator's request" do
      let!(:car_unpost)     { Fabricate(:unpost, creator: jen) }
      let!(:parent_message) { Fabricate(:user_unpost_message ) }
      let!(:reply_message ) { Fabricate(:reply_message       ) }
      before do
        spec_signin_user(jen)
        jen.update_column(:avatar, "1234abcd")
        request.env["HTTP_REFERER"] = "http://test.host/"
        UnimagesCleaner.should_receive(:perform_in)         #Mock UnimagesCleaner
        delete :destroy, user_id: jen.id, id: car_unpost.id
      end

      it "sets set the removed boolean to true" do
        expect(car_unpost.reload.inactive?).to be_true
      end
      it "sets the parent message's deleted_at to a time" do
        expect(parent_message.reload.deleted_at).to be_present
      end
      it "sets the parent message's deleted_at to a time" do
        expect(reply_message.reload.deleted_at).to be_present
      end
      it "it flashes a success message" do
        expect(flash[:success]).to be_present
      end
      it "redirects to back to the last page" do
        expect(response).to redirect_to :back
      end
    end

    context "with anyone besides the creator" do
      let(:car_unpost) { Fabricate(:unpost, creator: jen) }

      it_behaves_like "require_signed_in" do
        let(:verb_action) { delete :destroy, { user_id: jen.id, id: car_unpost.id } }
      end
      it_behaves_like "require_correct_user" do
        let(:verb_action) { delete :destroy, { user_id: jen.id, id: car_unpost.id } }
      end
    end
  end
end

def create_params
  params = {unpost: {category_id: 3,
                           title: "Volkswagen Bug",
                     description: "Want an awesome bug. Running. White with the number \"8\" on the side. ",
                    condition_id: 8,
                           price: 200,
                        keyword1: "volkswagen",
                        keyword2: "bug",
                        keyword3: "ocho",
                        keyword4: "",
                            link: "http://www.google.com"},
                        #   travel: true,
                        # distance: 3,
                        #  zipcode: 98056},
                         user_id: 1,
                        unimages: {} }
end

def update_params
  params = {unpost: {category_id: 3,
                           title: "Volkswagen Bug",
                     description: "Desperate. Running or not.",
                    condition_id: 8,
                           price: 200,
                        keyword1: "volkswagen",
                        keyword2: "bug",
                        keyword3: "ocho",
                        keyword4: "",
                            link: "http://www.herbie.com"},
                         user_id: jen.id, id: car_unpost.id}
end

def invalid_update_params
  params = {unpost: {category_id: 3,
                           title: nil,
                     description: "Desperate. Running or not.",
                    condition_id: 8,
                           price: 200,
                        keyword1: "volkswagen",
                        keyword2: "bug",
                        keyword3: "ocho",
                        keyword4: "",
                            link: "http://www.herbie.com"},
                        #   travel: true,
                        # distance: 3,
                        #  zipcode: 98056},
                         user_id: jen.id, id: car_unpost.id }
end

def invalid_create_params
  params = {unpost: {category_id: 3,
                           title: nil,
                     description: "Want an awesome bug. Running. White with the number \"8\" on the side. ",
                    condition_id: 8,
                           price: 200,
                        keyword1: "volkswagen",
                        keyword2: "bug",
                        keyword3: "ocho",
                        keyword4: "",
                            link: "http://www.google.com"},
                         user_id: 1}
end
