require 'spec_helper'

describe UnlistingsQuery, :vcr do
  let!(:settings) { Fabricate(:setting                  ) }
  let!(:seattle ) { Fabricate(:city_state_location      ) }
  let!(:portland) { Fabricate(:zip_location, zipcode: 97209, latitude: '45.52670', longitude: '-122.68805' ) }
  let!(:kirkland) { Fabricate(:location, zipcode: 98033 ) }
  let!(:jen     ) { Fabricate(:user                     ) }
  let!(:nicole  ) { Fabricate(:user                     ) }

  let!(:house_category          ) { Fabricate(:category,        name: "real estate"                        ) }
  let!(:bellevue_house_unlisting) { Fabricate(:unlisting,   keyword1: "housey", category: house_category   ) }
  let!(:portland_house_unlisting) { Fabricate(:unlisting,   keyword1: "housey", category: house_category   ) }
  let!(:car_unlisting           ) { Fabricate(:unlisting                                                   ) }
  let!(:bellevue_unlisting      ) { Fabricate(:unlisting                                                   ) }
  let!(:house_unlisting         ) { Fabricate(:unlisting,   keyword1: "housey", category: house_category   ) }
  let!(:protect_house_unlisting ) { Fabricate(:unlisting,   keyword1: "housey", category: house_category, visibility: "protected" ) }
  let!(:portland_unlisting      ) { Fabricate(:unlisting,    creator:  nicole                              ) }
  let!(:gift_unlisting          ) { Fabricate(:unlisting, visibility: "protected"                          ) }
  before do
    nicole.update_column(                          :location_id, 2)
    portland_house_unlisting.creator.update_column(:location_id, 2)
    bellevue_house_unlisting.creator.update_column(:location_id, 3)
    bellevue_unlisting.creator.update_column(      :location_id, 3)
  end


  context "for querying on the EVERYONE query" do               #USED FOR UNLISTINGS SEARCHES
    context "for city-state location" do                        #context: Everyone Query
      context "for a general search (not category-specific)" do #context: Everyone Query/City-State Location
        context "of everything (no keywords)" do                #context: Everyone Query/City-State Location/NO category
          context "within a 100 mile radius" do                 #context: Everyone Query/City-State Location/NO category/Everything(no keywords)
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "",
                                     search_visibility: "everyone",
                                           category_id: "0", #all categories
                                                radius: 100,
                                                  city: "seattle",
                                                 state: "wa",
                                               zipcode: nil)
            end

            it "does not return protected unlistings" do
              expect(search_results).to_not include( gift_unlisting  )
            end
            it "returns the unprotected unlistings within that range" do
              expect(search_results).to     include( car_unlisting, bellevue_unlisting, house_unlisting )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_unlisting )
            end
          end


          context "IN location (radius = '0')" do #context: "Everyone Query/City-State Location"/NO category/Everything(no keywords)
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "",
                                     search_visibility: "everyone",
                                           category_id: "0", #all categories
                                                radius: "0",
                                                  city: "seattle",
                                                 state: "wa",
                                               zipcode: nil)
            end

            it "does not return protected unlistings" do
              expect(search_results).to_not include( gift_unlisting  )
            end
            it "returns the unprotected unlistings within that range" do
              expect(search_results).to     include( car_unlisting, house_unlisting )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_unlisting, bellevue_unlisting )
            end
          end
        end



        context "for search of specific keywords" do #context: "Everyone Query/City-State Location"/NO category
          context "within a 100 mile radius" do      #context: "Everyone Query/City-State Location"/NO category/With Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "housey",
                                     search_visibility: "everyone",
                                           category_id: "0", #all categories
                                                radius: 100,
                                                  city: "seattle",
                                                 state: "wa",
                                               zipcode: nil)
            end

            it "returns only the unlistings that contain those keywords" do
              expect(search_results).to eq([bellevue_house_unlisting, house_unlisting])
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_house_unlisting )
            end
          end

          context "IN location (radius = '0')" do #context: "Everyone Query/City-State Location"/NO category/With Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "housey",
                                     search_visibility: "everyone",
                                           category_id: "0", #all categories
                                                radius: '0',
                                                  city: "seattle",
                                                 state: "wa",
                                               zipcode: nil)
            end

            it "returns only the unlistings that contain those keywords" do
              expect(search_results).to eq([house_unlisting])
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_house_unlisting )
            end
          end
        end
      end




      context "for search WITHIN a specific category" do #context: Everyone Query/City-State Location
        context "of everything (no keywords)" do         #context: Everyone Query/City-State Location/Specific Category
          context "within a 100 mile radius" do          #context: Everyone Query/City-State Location/Specific Category/No Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "",
                                     search_visibility: "everyone",
                                           category_id: house_category.id,
                                                radius: 100,
                                                  city: "seattle",
                                                 state: "wa",
                                               zipcode: nil)
            end

            it "does not return protected unlistings" do
              expect(search_results).to_not include( protect_house_unlisting )
            end
            it "returns the matching unlistings within that range" do
              expect(search_results).to     include( bellevue_house_unlisting, house_unlisting )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_house_unlisting )
            end
          end

          context "IN a specific city/state (radius = '0')" do #context: Everyone Query/City-State Location/Specific Category/No Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "",
                                     search_visibility: "everyone",
                                           category_id: house_category.id,
                                                radius: "0",
                                                  city: "seattle",
                                                 state: "wa",
                                               zipcode: nil)
            end

            it "does not return protected unlistings" do
              expect(search_results).to_not include( protect_house_unlisting  )
            end
            it "returns the matching unlistings within that range" do
              expect(search_results).to          eq( [house_unlisting] )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_unlisting, bellevue_unlisting )
            end
          end
        end



        context "for search of specific keywords" do #context: Everyone Query/City-State Location/Specific Category
          context "within a 100 mile radius" do #context: Everyone Query/City-State Location/Specific Category/With Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "housey",
                                     search_visibility: "everyone",
                                           category_id: house_category.id,
                                                radius: 100,
                                                  city: "seattle",
                                                 state: "wa",
                                               zipcode: nil)
            end

            it "returns only the unlistings that contain those keywords" do
              expect(search_results).to          eq( [bellevue_house_unlisting, house_unlisting] )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_house_unlisting )
            end
          end


          context "IN a specific city/state (radius = '0')" do #context: Everyone Query/City-State Location/Specific Category/With Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "housey",
                                     search_visibility: "everyone",
                                           category_id: house_category.id,
                                                radius: '0',
                                                  city: "seattle",
                                                 state: "wa",
                                               zipcode: nil)
            end

            it "returns only the unlistings that contain those keywords" do
              expect(search_results).to          eq( [house_unlisting] )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_house_unlisting )
            end
          end
        end
      end
    end




    context "for zipcode location" do                           #context: Everyone Query
      context "for a general search (not category-specific)" do #context: Everyone Query/City-State Location
        context "of everything (no keywords)" do                #context: Everyone Query/City-State Location/NO category
          context "within a 100 mile radius" do                 #context: Everyone Query/City-State Location/NO category/Everything(no keywords)
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "",
                                     search_visibility: "everyone",
                                           category_id: "0", #all categories
                                                radius: 100,
                                                  city: nil,
                                                 state: nil,
                                               zipcode: 98164)
            end

            it "does not return protected unlistings" do
              expect(search_results).to_not include( gift_unlisting  )
            end
            it "returns the unprotected unlistings within that range" do
              expect(search_results).to     include( car_unlisting, bellevue_unlisting, house_unlisting )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_unlisting )
            end
          end


          context "IN location (radius = '0')" do #context: "Everyone Query/City-State Location"/NO category/Everything(no keywords)
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "",
                                     search_visibility: "everyone",
                                           category_id: "0", #all categories
                                                radius: "0",
                                                  city: nil,
                                                 state: nil,
                                               zipcode: 98164)
            end

            it "does not return protected unlistings" do
              expect(search_results).to_not include( gift_unlisting  )
            end
            it "returns the unprotected unlistings within that range" do
              expect(search_results).to     include( car_unlisting, house_unlisting )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_unlisting, bellevue_unlisting )
            end
          end
        end



        context "for search of specific keywords" do #context: "Everyone Query/City-State Location"/NO category
          context "within a 100 mile radius" do      #context: "Everyone Query/City-State Location"/NO category/With Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "housey",
                                     search_visibility: "everyone",
                                           category_id: "0", #all categories
                                                radius: 100,
                                                  city: nil,
                                                 state: nil,
                                               zipcode: 98164)
            end

            it "returns only the unlistings that contain those keywords" do
              expect(search_results).to eq([bellevue_house_unlisting, house_unlisting])
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_house_unlisting )
            end
          end

          context "IN location (radius = '0')" do #context: "Everyone Query/City-State Location"/NO category/With Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "housey",
                                     search_visibility: "everyone",
                                           category_id: "0", #all categories
                                                radius: '0',
                                                  city: nil,
                                                 state: nil,
                                               zipcode: 98164)
            end

            it "returns only the unlistings that contain those keywords" do
              expect(search_results).to eq([house_unlisting])
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_house_unlisting )
            end
          end
        end
      end




      context "for search WITHIN a specific category" do #context: Everyone Query/City-State Location
        context "of everything (no keywords)" do         #context: Everyone Query/City-State Location/Specific Category
          context "within a 100 mile radius" do          #context: Everyone Query/City-State Location/Specific Category/No Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "",
                                     search_visibility: "everyone",
                                           category_id: house_category.id,
                                                radius: 100,
                                                  city: nil,
                                                 state: nil,
                                               zipcode: 98164)
            end

            it "does not return protected unlistings" do
              expect(search_results).to_not include( protect_house_unlisting )
            end
            it "returns the matching unlistings within that range" do
              expect(search_results).to     include( bellevue_house_unlisting, house_unlisting )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_house_unlisting )
            end
          end

          context "IN a specific city/state (radius = '0')" do #context: Everyone Query/City-State Location/Specific Category/No Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "",
                                     search_visibility: "everyone",
                                           category_id: house_category.id,
                                                radius: "0",
                                                  city: nil,
                                                 state: nil,
                                               zipcode: 98164)
            end

            it "does not return protected unlistings" do
              expect(search_results).to_not include( protect_house_unlisting  )
            end
            it "returns the matching unlistings within that range" do
              expect(search_results).to          eq( [house_unlisting] )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_unlisting, bellevue_unlisting )
            end
          end
        end



        context "for search of specific keywords" do #context: Everyone Query/City-State Location/Specific Category
          context "within a 100 mile radius" do #context: Everyone Query/City-State Location/Specific Category/With Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "housey",
                                     search_visibility: "everyone",
                                           category_id: house_category.id,
                                                radius: 100,
                                                  city: nil,
                                                 state: nil,
                                               zipcode: 98164)
            end

            it "returns only the unlistings that contain those keywords" do
              expect(search_results).to          eq( [bellevue_house_unlisting, house_unlisting] )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_house_unlisting )
            end
          end


          context "IN a specific city/state (radius = '0')" do #context: Everyone Query/City-State Location/Specific Category/With Keywords
            let(:search_results) do
              UnlistingsQuery.new.search(search_string: "housey",
                                     search_visibility: "everyone",
                                           category_id: house_category.id,
                                                radius: '0',
                                                  city: nil,
                                                 state: nil,
                                               zipcode: 98164)
            end

            it "returns only the unlistings that contain those keywords" do
              expect(search_results).to          eq( [house_unlisting] )
            end
            it "does not return unlistings outside of the radius" do
              expect(search_results).to_not include( portland_house_unlisting )
            end
          end
        end
      end
    end
  end
end

