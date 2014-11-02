require 'spec_helper'

describe UnlistingsQuery, :vcr do
  let!(:settings) { Fabricate(:setting            ) }
  let!(:jen     ) { Fabricate(:user               ) }
  let!(:seattle ) { Fabricate(:city_state_location) }

  let!(:car_unlisting   ) { Fabricate(:unlisting) }
  let!(:phone_unlisting ) { Fabricate(:unlisting) }
  let!(:house_unlisting ) { Fabricate(:unlisting) }
  let!(:gift_unlisting  ) { Fabricate(:unlisting, visibility: "protected") }

  context "for querying on the general search" do
    context "for city/state location"
      context "for a general search of everything within 100 miles of location" do
        let(:search_results) do
          UnlistingsQuery.new.search(search_string: "",
                                 search_visibility: "everyone",
                                      cateogory_id: "0", #all categories
                                            radius: 100,
                                              city: "seattle",
                                             state: "wa",
                                           zipcode: nil)
        end

        it "does not return protected unlistings" do
          expect(search_results).to_not include( gift_unlisting  )
        end
        it "returns the unprotected unlistings within that range" do
          expect(search_results).to include( car_unlisting,
                                             phone_unlisting,
                                             house_unlisting )
        end

        it "does not return unlistings outside of the radius"
      end

      context "for specific search of keywords" do
        it "returns only the unlistings that contain those keywords"
        it "returns only the unlistings within the given radius from location specified"

      end
    context "for zipcode location" do
      #essentially a copy of city/state stuff here, but cut lots down as can.
    end
  end
end
