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
        expect(Unpost.count).to eq(2)
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



  describe "GET search" do
    let!(:autos)          { Fabricate(:category,   name: "autos") }
    let!(:honda_van)      { Fabricate(:unpost, category: autos, keyword1: "honda van") }
    let!(:honda_car)      { Fabricate(:unpost, category: autos, keyword1: "honda civic") }
    let!(:honda_mower)    { Fabricate(:unpost,                  keyword1: "honda mower") }
    let!(:toyota_vehicle) { Fabricate(:unpost, category: autos, keyword1: "toyota hond") }
    let!(:toyota_truck)   { Fabricate(:unpost, category: autos, keyword1: "toyota truck") }

    context "with specific category selected" do
      before { get :search, { keyword: "honda", category_id: autos.id } }

      it "returns the matching OR partial-matching table row objects" do
        expect(assigns(:search_results)).to include(honda_van, honda_car)
      end
      it "only returns values from the selected category" do
        expect(assigns(:search_results).map(&:category_id)).to eq([1,1])
      end
      it "does not return other values with non-keyword matches" do
        expect(assigns(:search_results)).to_not include(toyota_vehicle)
        expect(assigns(:search_results)).to_not include(toyota_truck)
      end
      it "returns the original keyword search value for use" do
        expect(assigns(:search_string)).to eq("honda")
      end
      it "renders the main search page" do
        expect(response).to render_template 'search'
      end
    end

    context "with 'ALL' categories selected" do
      before { get :search, { keyword: "honda", category_id: 0 } }

      it "returns the matching OR partial-matching table row objects" do
        expect(assigns(:search_results)).to include(honda_van, honda_car, honda_mower)
      end
      it "returns values from multiple categories" do
        expect(assigns(:search_results).map(&:category_id)).to eq([1,1,2])
      end
      it "does not return other values with non-keyword matches" do
        expect(assigns(:search_results)).to_not include(toyota_vehicle)
        expect(assigns(:search_results)).to_not include(toyota_truck)
      end
      it "returns the original keyword search value for use" do
        expect(assigns(:search_string)).to eq("honda")
      end
      it "renders the main search page" do
        expect(response).to render_template 'search'
      end
    end
  end



  describe "DELETE destroy" do
    context "with the creator's request" do
      let(:car_unpost) { Fabricate(:unpost, creator: jen) }
      before do
        spec_signin_user(jen)
        request.env["HTTP_REFERER"] = "http://test.host/"
        delete :destroy, user_id: jen.id, id: car_unpost.id
      end

      it "sets set the removed boolean to true" do
        expect(car_unpost.reload.inactive?).to be_true
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

# => {unpost:
#   {category_id: "2",
#     title: "Dominion Boardgame",
#     description:
#      "Dominion Boardgame with or without expansions in new or gently used condition.",
#     link: "http://www.amazon.com/",
#     condition_id: "6",
#     price: "15",
#     keyword1: "Dominion",
#     keyword2: "Boardgame",
#     keyword3: "board game",
#     keyword4: "",
#     unimages_attributes: {"0"=>{"filename"=>""}}},
#     unimages:
#       {filename:
#       [#<ActionDispatch::Http::UploadedFile:0x007f84898d3c80
#         @content_type="image/jpeg",
#         @headers=
#           "Content-Disposition: form-data; name=\"unimages[filename][]\"; filename=\"PD_0071_143_632795A.jpeg\"\r\nContent-Type: image/jpeg\r\n",
#         @original_filename="PD_0071_143_632795A.jpeg",
#         @tempfile=
#         #<File:/var/folders/_n/nnlnp20x0gn5myzjw8f187dc0000gn/T/RackMultipart20140630-21787-jsoalg>>,
#        #<ActionDispatch::Http::UploadedFile:0x007f84898d3c30
#         @content_type="image/png",
#         @headers=
#        "Content-Disposition: form-data; name=\"unimages[filename][]\"; filename=\"Screen Shot 2014-03-26 at 3.27.25 PM.png\"\r\nContent-Type: image/png\r\n",
#         @original_filename="Screen Shot 2014-03-26 at 3.27.25 PM.png",
#         @tempfile=
#         #<File:/var/folders/_n/nnlnp20x0gn5myzjw8f187dc0000gn/T/RackMultipart20140630-21787-1n1elqk>>]},
#     commit: "Create Unpost",
#     action: "create",
#     controller: "unposts",
#     user_id: 1 }


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
                        #   travel: true,
                        # distance: 3,
                        #  zipcode: 98056},
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
                            link: "http://www.google.com",
                          travel: true,
                        distance: 3,
                         zipcode: 98056},
                         user_id: 1}
end
