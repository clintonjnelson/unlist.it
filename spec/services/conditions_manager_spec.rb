require 'spec_helper'

describe ConditionsManager do
  let!(:settings) { Fabricate(:setting) }
  let!(:autos)    { Fabricate(:category, name: 'autos') }
  let!(:good)     { Fabricate(:condition, category: autos, level: 'good') }
  let!(:fair)     { Fabricate(:condition, category: autos, level: 'fair') }
  let!(:poor)     { Fabricate(:condition, category: autos, level: 'poor') }

  describe "for a new condition creation" do
    context "with valid input" do
      let(:exist_conds_params) { [{ 'id' => good.id, 'position' => '2' },
                                  { 'id' => fair.id, 'position' => '4' },
                                  { 'id' => poor.id, 'position' => '5' }] }  #"conditions"=>[{"id"=>"17", "'position'"=>"1"}, {"id"=>"15", "position"=>"2"}]

      it "returns 'true'" do
        new_cond_params = { id: nil, level: "mint", position: 1 }
        response = ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params)
          verify_the_correct_condition
          expect(response).to eq(true)
      end
      it "makes a new condition" do
        new_cond_params = { id: nil, level: "mint", position: 1 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params)
          expect(Condition.last.level).to eq("mint")
      end
      it "references the provided category" do
        new_cond_params = { id: nil, level: "mint", position: 1 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params)
          verify_the_correct_condition
          expect(Condition.last.category.name).to eq("autos")
      end
      it "with a provided FIRST position, is in the first position" do
        new_cond_params = { id: nil, level: "mint", position: 1 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params)
          verify_the_correct_condition
          expect(Condition.last.position).to eq(1)
      end
      it "with a provided MID position, is in the MID position" do
        new_cond_params = { id: nil, level: "mint", position: 3 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params)
          verify_the_correct_condition
          expect(Condition.last.position).to eq(2)
      end
      it "with a provided LAST position, is in the last position" do
        new_cond_params = { id: nil, level: "mint", position: 6 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params)
          verify_the_correct_condition
          expect(Condition.last.position).to eq(4)
      end
    end

    context "with INvalid input" do
      let(:exist_conds_params) { [{ 'id' => good.id, 'position' => '2' },
                                  { 'id' => fair.id, 'position' => '4' },
                                  { 'id' => poor.id, 'position' => '5' }] }  #"conditions"=>[{"id"=>"17", "'position'"=>"1"}, {"id"=>"15", "position"=>"2"}]

      it "returns 'false'" do
        new_cond_params = { id: nil, level: "", position: 2 }
        response = ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params)
          expect(response).to eq(false)
      end
      it "DOES NOT make a new condition" do
        new_cond_params = { id: nil, level: "", position: 2 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params)
          expect(Condition.last.level).to eq("poor")
      end
      it "does not allow duplicate positions" do
        new_cond_params = { id: nil, level: "mint", position: 2 }
        response = ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params)
          expect(response).to be_false
      end
    end
  end


  describe "for an existing condition update" do
    context "with valid input" do
      let(:exist_conds_params) { [{ 'id' => good.id, 'position' => '2' },
                                  { 'id' => poor.id, 'position' => '5' }] }  #"conditions"=>[{"id"=>"17", "'position'"=>"1"}, {"id"=>"15", "position"=>"2"}]

      it "updates the condition name" do
        new_cond_params = { id: fair.id, level: "faaaair", position: 1 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params, new_cond_params[:id])
          expect(Condition.find(fair.id).level).to eq("faaaair")
      end
      it "with a provided FIRST position, updates object to the FIRST position" do
        new_cond_params = { id: fair.id, level: "faaaair", position: 1 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params, new_cond_params[:id])
          expect(Condition.find(fair.id).position).to eq(1)
      end
      it "with a provided MID position, updates object to the MID position" do
        new_cond_params = { id: fair.id, level: "faaaair", position: 4 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params, new_cond_params[:id])
          expect(Condition.find(fair.id).position).to eq(2)
      end
      it "with a provided LAST position, updates object to the LAST position" do
        new_cond_params = { id: fair.id, level: "faaaair", position: 9 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params, new_cond_params[:id])
          expect(Condition.find(fair.id).position).to eq(3)
      end
    end

    context "with INvalid input" do
      let(:exist_conds_params) { [{ 'id' => good.id, 'position' => '2' },
                                  { 'id' => poor.id, 'position' => '5' }] }  #"conditions"=>[{"id"=>"17", "'position'"=>"1"}, {"id"=>"15", "position"=>"2"}]

      it "returns 'false'" do
        new_cond_params = { id: fair.id, level: "", position: 2 }
        response = ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params, new_cond_params[:id])
          expect(response).to eq(false)
      end
      it "DOES NOT update the condition name" do
        new_cond_params = { id: fair.id, level: "", position: 1 }
        ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params, new_cond_params[:id])
          expect(Condition.find(fair.id).level).to eq("fair")
      end
      it "DOES NOT allow duplicate positions" do
        new_cond_params = { id: fair.id, level: "faaaair", position: 2 }
        response = ConditionsManager.new(autos).add_or_update_condition(new_cond_params, exist_conds_params, new_cond_params[:id])
          expect(response).to eq(false)
      end
    end
  end
end

def verify_the_correct_condition
  expect(Condition.last.level).to eq("mint")
end
