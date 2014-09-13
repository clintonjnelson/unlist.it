require 'spec_helper'

describe Admin::CategoriesController do
  let!(:settings) { Fabricate(:setting) }
  let!(:jen)      { Fabricate(:admin) }
  let!(:autos)    { Fabricate(:category, name: 'autos') }
  before          { jen.update_column(:role,   "admin") }

  describe "authorization & access" do
    context "for unauthorized users (ie: NON-admin)" do
      it_behaves_like "require_admin" do
        let(:verb_action) { get :new }
      end
    end
  end


  describe "GET new" do
    before do
      spec_signin_user(jen)
      get :new
    end
    it "makes a new instance of @category" do
      expect(assigns(:category)).to be_a_new Category
    end
    it "renders the new template" do
      expect(response).to render_template 'new'
    end
  end


  describe "POST create" do
    context "with valid inputs" do
      before do
        spec_signin_user(jen)
        post :create, { category: { name: 'games' } }
      end
      it "makes a valid instance of @category" do
        expect(assigns(:category)).to be_valid
      end
      it "makes a new Category object" do
        expect(Category.last.name).to eq("games")
      end
      it "flashes a success with the name in the message" do
        expect(flash[:success]).to include("games")
      end
      it "redirects to the new conditions page" do
        expect(response).to redirect_to new_admin_condition_path
      end
    end

    context "with INvalid inputs" do
      before do
        spec_signin_user(jen)
        post :create, { category: { name: "" } }
      end
      it "makes an INvalid instance of @category" do
        expect(assigns(:category)).to_not be_valid
      end
      it "DOES NOT make a new Category object" do
        expect(Category.count).to eq(1)
      end
      it "flashes an error message" do
        expect(flash[:error]).to be_present
      end
      it "renders the new category page again" do
        expect(response).to render_template 'new'
      end
    end
  end


  describe "GET edit" do
    before do
      spec_signin_user(jen)
      get :edit, { id: autos.slug }
    end
    it "loads the category to be edited" do
      expect(assigns(:category)).to eq(autos)
    end
    it "renders the new template" do
      expect(response).to render_template 'edit'
    end
  end


  describe "PATCH update" do
    context "with valid information" do
      before do
        spec_signin_user(jen)
        patch :update, { id: autos.slug, category: { name: 'autoes' } }
      end
      it "loads the category to be edited" do
        expect(assigns(:category)).to be_present
      end
      it "it is valid" do
        expect(assigns(:category)).to be_valid
      end
      it "updates the Category in the database" do
        expect(Category.find(autos.id).name).to eq('autoes')
      end
      it "flashes a success message" do
        expect(flash[:success]).to be_present
      end
      it "redirects to the category index path" do
        expect(response).to redirect_to admin_categories_path
      end
    end

    context "with valid information" do
      before do
        spec_signin_user(jen)
        patch :update, { id: autos.slug, category: { name: '' } }
      end
      it "loads the category to be edited" do
        expect(assigns(:category)).to be_present
      end
      it "is NOT valid" do
        expect(assigns(:category)).to_not be_valid
      end
      it "does NOT update the Category in the database" do
        expect(Category.find(autos.id).name).to_not eq('autoes')
      end
      it "flashes an error message" do
        expect(flash[:error]).to be_present
      end
      it "renders the edit template again for error display" do
        expect(response).to render_template 'edit'
      end
    end
  end


  describe "GET index" do
    before do
      spec_signin_user(jen)
      get :index
    end
    it "loads all of the categories @categories" do
      expect(assigns(:categories)).to be_present
    end
    it "renders the new template" do
      expect(response).to render_template 'index'
    end
  end


  describe "DELETE destroy" do
    let!(:games) { Fabricate(:category,   name: 'games'                ) }
    let!(:good)  { Fabricate(:condition, level: 'good', category: games) }
    let!(:fair)  { Fabricate(:condition, level: 'fair', category: games) }
    before do
      spec_signin_user(jen)
      delete :destroy, { id: games.slug }
    end
    it "destroys the requested category" do
      expect(Category.where(name: "games" )).to eq([])
    end
    it "destroys all of the dependent conditions" do
      expect(Condition.where(category_id: games.id)).to eq([])
    end
    it "flashes a success message" do
      expect(flash[:success]).to be_present
    end
    it "redirects to the categories path" do
      expect(response).to redirect_to admin_categories_path
    end
  end
end
