require 'spec_helper'

describe Admin::ConditionsController do
  let(:jen) { Fabricate(:admin) }
  let!(:autos) { Fabricate(:category, name: "autos") }
  let!(:good)  { Fabricate(:condition, category: autos, level: "good", order: 1) }
  let!(:bad)   { Fabricate(:condition, category: autos, level: "bad", order: 2) }

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
    context "for valid information with adding to standard order" do
      before do
        spec_signin_user(jen)
        get :create, { condition: { category_id: 1, level: "average", order: 2 },
                      conditions: [ { id: "1", order: "1" } ] }
        #"condition"=>{"category_id"=>"1", "level"=>"good", "order"=>"2"}, "conditions"=>[{"id"=>"1", "order"=>"3"}], "commit"=>"Add Condition", "action"=>"create", "controller"=>"admin/conditions"}
      end

      it "sets the category to be the chosen category" do
        expect(assigns(:category)).to eq(autos)
      end
      it "builds a valid Condition" do
        expect(assigns(:condition)).to be_valid
      end
      it "reorders the conditions in the order given"

      it "redirects to the categories index page" do
        expect(response).to redirect_to admin_categories_path
      end
    end

    describe "verifying proper reordering: " do
      before { spec_signin_user(jen) }

      it "reorders from 1, based on relative number order provided" do
        get :create, { condition: { category_id: 1, level: "average", order: 99 },
                      conditions: [ { id: "1", order: "2" }, { id: "2", order: "1" } ] }
        expect(Condition.first.order).to eq(2)
        expect(Condition.last.order).to eq(3)
      end
      it "the order will not change if proper ordering is provided" do
        get :create, { condition: { category_id: 1, level: "average", order: 1 },
                      conditions: [ { id: "1", order: "3" }, { id: "2", order: "2" } ] }
        expect(Condition.first.order).to eq(3)
        expect(Condition.last.order).to eq(1)
      end
    end

    context "for INvalid condition information" do
      before do
        spec_signin_user(jen)
        get :create, { condition: { category_id: 1, level: nil, order: 3 },
                      conditions: [ { id: "1", order: "1" }, { id: "2", order: "2" } ] }
        #"condition"=>{"category_id"=>"1", "level"=>"good", "order"=>"2"}, "conditions"=>[{"id"=>"1", "order"=>"3"}], "commit"=>"Add Condition", "action"=>"create", "controller"=>"admin/conditions"}
      end
      it "sets the category to be the chosen category" do
        expect(assigns(:category)).to eq(autos)
      end
      it "sets a new instance of a condition" do
        expect(assigns(:condition)).to be_a_new Condition
      end
      it "is not a valid @condition" do
        expect(assigns(:condition)).to_not be_valid
      end
      it "does not create a new condition" do
        expect(Condition.count).to eq(2)
      end
      it "flashes an error message" do
        expect(flash[:error]).to be_present
      end
      it "RE-renders the new template" do
        expect(response).to render_template 'new'
      end
    end

    context "with invalid order provided" do
      before do
        spec_signin_user(jen)
        get :create, { condition: { category_id: 1, level: "average", order: 1 },
                      conditions: [ { id: "1", order: "1" }, { id: "2", order: "2" } ] }
        #"condition"=>{"category_id"=>"1", "level"=>"good", "order"=>"2"}, "conditions"=>[{"id"=>"1", "order"=>"3"}], "commit"=>"Add Condition", "action"=>"create", "controller"=>"admin/conditions"}
      end
      it "maintains the original order - not allowing duplicates" do
        expect(Condition.first.order).to eq(1)
        expect(Condition.last.order).to eq(2)
      end
      it "does not create a new condition" do
        expect(Condition.count).to eq(2)
      end
      it "flashes an error message" do
        expect(flash[:error]).to be_present
      end
      it "RE-renders the new template" do
        expect(response).to render_template 'new'
      end
    end
  end

end
