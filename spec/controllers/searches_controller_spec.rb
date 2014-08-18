require 'spec_helper'


describe SearchesController do
  let!(:jen) { Fabricate(:user) }

  describe "GET search" do
    describe "GET search" do
    let!(:autos)          { Fabricate(:category,     name: "autos"                        ) }
    let!(:honda_van)      { Fabricate(:unlisting,   category:  autos, keyword1: "honda van"   ) }
    let!(:honda_car)      { Fabricate(:unlisting,   category:  autos, keyword1: "honda civic" ) }
    let!(:honda_mower)    { Fabricate(:unlisting,                     keyword1: "honda mower" ) }
    let!(:toyota_vehicle) { Fabricate(:unlisting,   category:  autos, keyword1: "toyota hond" ) }
    let!(:toyota_truck)   { Fabricate(:unlisting,   category:  autos, keyword1: "toyota truck") }

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
  end
end
