require 'spec_helper'

#Note: mocks the ConditionsManager service object

describe Admin::ConditionsController do
  let!(:settings) { Fabricate(:setting) }
  let(:jen)       { Fabricate(:admin) }
  let!(:autos)    { Fabricate(:category, name: "autos") }
  let!(:good)     { Fabricate(:condition, category: autos, level: "good", position: 1) }
  let!(:bad)      { Fabricate(:condition, category: autos, level: "bad", position: 2) }

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
        ConditionsManager.any_instance.should_receive(:add_or_update_condition).and_return(true)
        spec_signin_user(jen)
        post :create, { condition: { category_id: 1, level: "average", position: 2 },
                       conditions: [ { id: "1", position: "1" } ] }
      end

      it "sets the category to be the chosen category" do
        expect(assigns(:category)).to eq(autos)
      end
      it "redirects to the categories index page" do
        expect(response).to redirect_to new_admin_condition_path
      end
    end

    context "for valid condition info on a NEW category with no prior conditions" do
      let!(:games) { Fabricate(:category) }
      before do
        ConditionsManager.any_instance.should_receive(:add_or_update_condition).and_return(true)
        spec_signin_user(jen)
        post :create, { condition: { category_id: 2, level: "new", position: 2 },
                       conditions: [ ] }
      end
      it "sets the category to be the chosen category" do
        expect(assigns(:category)).to eq(games)
      end
      it "redirects to the new condition page" do
        expect(response).to redirect_to new_admin_condition_path
      end
    end

    context "for INvalid condition information" do
      before do
        ConditionsManager.any_instance.should_receive(:add_or_update_condition).and_return(false)
        spec_signin_user(jen)
        post :create, { condition: { category_id: 1, level: nil, position: 3 },
                       conditions: [ { id: "1", position: "1" }, { id: "2", position: "2" } ] }
      end
      it "sets the category to be the chosen category" do
        expect(assigns(:category)).to eq(autos)
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
        ConditionsManager.any_instance.should_receive(:add_or_update_condition).and_return(false)
        spec_signin_user(jen)
        post :create, { condition: { category_id: 1, level: "average", position: 1 },
                       conditions: [ { id: "1", position: "1" }, { id: "2", position: "2" } ] }
      end
      it "flashes an error message" do
        expect(flash[:error]).to be_present
      end
      it "redirects to the new condition path" do
        expect(response).to redirect_to new_admin_condition_path
      end
    end
  end


  describe "GET edit" do
    before do
      spec_signin_user(jen)
      get :edit, { id: bad.id }
    end
    it "loads the category to be edited" do
      expect(assigns(:condition)).to eq(bad)
    end
    it "loads the other conditions for the category" do
      expect(assigns(:other_conditions)).to eq([good])
    end
    it "renders the new template" do
      expect(response).to render_template 'edit'
    end
  end


  describe "PATCH update" do
    context "with valid information" do
      before do
        ConditionsManager.any_instance.should_receive(:add_or_update_condition).and_return(true)
        spec_signin_user(jen)
        patch :update, { id: bad.id, condition: { category_id: bad.category_id, level: 'badd', position: 4 },
                                    conditions: [{id: "#{good.id}", position: "#{good.position}" }] }
      #"condition"=>{"category_id"=>"2", "level"=>"perfecto", "position"=>"5"}, "conditions"=>[{"id"=>"19", "position"=>"1"}, {"id"=>"24", "position"=>"3"}, {"id"=>"21", "position"=>"4"}], "commit"=>"Save Changes", "action"=>"update", "controller"=>"admin/conditions", "id"=>"20"}

      end
      it "loads the condition to be edited" do
        expect(assigns(:condition)).to be_present
      end
      it "loads the associated category" do
        expect(assigns(:category)).to be_present
      end
      it "it is valid" do
        expect(assigns(:condition)).to be_valid
      end
      it "flashes a success message" do
        expect(flash[:success]).to be_present
      end
      it "redirects to the category index path" do
        expect(response).to redirect_to admin_categories_path
      end
    end

    context "with INvalid information" do
      before do
        ConditionsManager.any_instance.should_receive(:add_or_update_condition).and_return(false)
        spec_signin_user(jen)
        patch :update, { id: bad.id, condition: { category_id: bad.category_id, level: '', position: bad.position },
                                    conditions: [{id: "#{good.id}", position: "#{good.position}" }] }
      end
      it "loads the condition to be edited" do
        expect(assigns(:condition)).to be_present
      end
      it "loads the associated category" do
        expect(assigns(:category)).to be_present
      end
      it "flashes an error message" do
        expect(flash[:error]).to be_present
      end
      it "renders the edit template again for error display" do
        expect(response).to render_template 'edit'
      end
    end
  end


  describe "DELETE destroy" do
    context "for authorized admin user" do
      before do
        spec_signin_user(jen)
        delete :destroy, { id: bad.id }
      end
      it "deletes the requested condition" do
        expect(Condition.where(level: "bad" )).to eq([])
        expect(Condition.where(level: "good")).to eq([good])
      end
      it "flashed a success message" do
        expect(flash[:success]).to be_present
      end
      it "redirects to the category index page" do
        expect(response).to redirect_to admin_categories_path
      end
    end
  end
end
