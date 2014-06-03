require 'spec_helper'

describe Admin::ConditionsController do
  let(:jen) { Fabricate(:admin) }
  let!(:autos) { Fabricate(:category, name: "autos") }
  let!(:good)  { Fabricate(:condition, category: autos, level: "good", position: 1) }
  let!(:bad)   { Fabricate(:condition, category: autos, level: "bad", position: 2) }

  describe "authorization & access" do
    context "for unauthorized users (ie: NON-admin)" do
      it_behaves_like "require_admin" do
        let(:verb_action) { get :conditions_by_category }
      end
    end
  end

  describe "GET new" do
    context "for authorized admin user" do
      before do
        spec_signin_user(jen)
        get :new
      end
      it "sets a new instance of a condition" do
        expect(assigns(:condition)).to be_a_new Condition
      end
      it "renders the new template" do
        expect(response).to render_template 'new'
      end
    end
  end

  describe "GET conditions_by_category" do
    context "for authorized admin user" do
      before do
        spec_signin_user(jen)
        post :conditions_by_category, { format: 'js', category_id: autos.id }
      end
      it "sets the @conditions instance variable associated with a given category object" do
        expect(assigns(:conditions)).to eq([good, bad])
      end
      it "renders the conditions_for_category JS Ajax template update" do
        expect(response).to render_template 'conditions_by_category'
      end
    end
  end

  describe "GET create" do
    context "for valid information with adding to standard position" do
      before do
        spec_signin_user(jen)
        get :create, { condition: { category_id: 1, level: "average", position: 2 },
                      conditions: [ { id: "1", position: "1" } ] }
      end

      it "sets the category to be the chosen category" do
        expect(assigns(:category)).to eq(autos)
      end
      it "redirects to the categories index page" do
        expect(response).to redirect_to admin_categories_path
      end
    end

    describe "verifying proper reordering: " do
      before { spec_signin_user(jen) }

      it "reorders from 1, based on relative number position provided" do
        get :create, { condition: { category_id: 1, level: "worse", position: 99 },
                      conditions: [ { id: "1", position: "2" }, { id: "2", position: "1" } ] }
        worse = Condition.where(level: "worse").take
        expect(Condition.all).to eq([good, bad, worse])
      end
      it "the order will be exact if proper positioning is provided" do
        get :create, { condition: { category_id: 1, level: "average", position: 1 },
                      conditions: [ { id: "1", position: "3" }, { id: "2", position: "2" } ] }
        expect(Condition.find(1).position).to eq(3)
        expect(Condition.last.position).to eq(1)
      end
    end

    context "for INvalid condition information" do
      before do
        spec_signin_user(jen)
        get :create, { condition: { category_id: 1, level: nil, position: 3 },
                      conditions: [ { id: "1", position: "1" }, { id: "2", position: "2" } ] }
      end
      it "sets the category to be the chosen category" do
        expect(assigns(:category)).to eq(autos)
      end
      it "does not create a new condition" do
        expect(Condition.count).to eq(2)
      end
      it "flashes an error message" do
        expect(flash[:error]).to be_present
      end
      it "redirects the new condition path" do
        expect(response).to redirect_to new_admin_condition_path
      end
    end

    context "with invalid order provided" do
      before do
        spec_signin_user(jen)
        get :create, { condition: { category_id: 1, level: "average", position: 1 },
                      conditions: [ { id: "1", position: "1" }, { id: "2", position: "2" } ] }
      end
      it "maintains the original position - not allowing duplicates" do
        expect(Condition.first.position).to eq(1)
        expect(Condition.last.position).to eq(2)
      end
      it "does not create a new condition" do
        expect(Condition.count).to eq(2)
      end
      it "flashes an error message" do
        expect(flash[:error]).to be_present
      end
      it "redirects to the new condition path" do
        expect(response).to redirect_to new_admin_condition_path
      end
    end
  end

end
