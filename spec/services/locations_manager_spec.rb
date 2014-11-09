require 'spec_helper'

describe LocationsManager, :vcr do
  let!(:settings     ) { Fabricate(:setting            ) }
  let!(:seattle_city ) { Fabricate(:city_state_location) }
  let!(:seattle_zip  ) { Fabricate(:zip_location       ) }
  let( :location     ) { LocationsManager.new            }

  describe "find_or_make_location" do

    context "with a valid zipcode input" do
      context "for a new zipcode" do
        it "creates a new location" do
          location_count = Location.count
          location.find_or_make_location('98033')
            expect(Location.count).to eq(location_count + 1) #adds new location
        end
        it "sets the new zipcode" do
          location.find_or_make_location('98033')
            expect(Location.last.zipcode).to eq(98033)
        end
        it "returns type, latitude, longitude, city, state, success, id for use" do
          location.find_or_make_location('98033')
            expect(location.type     ).to eq( "Zipcode"    )
            expect(location.latitude ).to eq( 47.6688298   )
            expect(location.longitude).to eq( -122.1923875 )
            expect(location.city     ).to eq( nil          )
            expect(location.state    ).to eq( nil          )
            expect(location.success  ).to eq( true         )
            expect(location.id       ).to eq( 3            )
        end
      end

      context "for an existing zipcode" do
        it "does NOT create a new location" do
          location_count = Location.count
          location.find_or_make_location('98164')
            expect(Location.count).to eq(location_count) #no change
        end
        it "returns type, latitude, longitude, city, state, success, id for use" do
          location.find_or_make_location('98164')
            expect(location.type     ).to eq( "Zipcode"    )
            expect(location.latitude ).to eq( 47.606503    )
            expect(location.longitude).to eq( -122.3323955 )
            expect(location.city     ).to eq( nil          )
            expect(location.state    ).to eq( nil          )
            expect(location.success  ).to eq( true         )
            expect(location.id       ).to eq( 1            )
        end
      end
    end

    context "with a valid city-state location" do
      context "for a new city-state" do
        it "creates a new location" do
          location_count = Location.count
          location.find_or_make_location('PORTLAND, OR')
            expect(Location.count).to eq(location_count + 1) #adds new location
        end
        it "sets the new zipcode" do
          location.find_or_make_location('POrtLAnD, OR')
            expect(Location.last.city).to  eq('portland')
            expect(Location.last.state).to eq('or')
        end
        it "returns type, latitude, longitude, city, state, success, id for use" do
          location.find_or_make_location('Portland, OR')
            expect(location.type     ).to eq( "Place"    )
            expect(location.latitude ).to eq( 45.5234515   )
            expect(location.longitude).to eq( -122.6762071 )
            expect(location.city     ).to eq( 'Portland'   )
            expect(location.state    ).to eq( 'OR'         )
            expect(location.success  ).to eq( true         )
            expect(location.id       ).to eq( 3            )
        end
      end

      context "for an existing city-state" do
        it "does NOT create a new location" do
          location_count = Location.count
          location.find_or_make_location('sEaTtLE, wA')
            expect(Location.count).to eq(location_count) #no change
        end
        it "returns type, latitude, longitude, city, state, success, id for use" do
          location.find_or_make_location('sEATtle, wa')
            expect(location.type     ).to eq( "Place"      )
            expect(location.latitude ).to eq( 47.606503    )
            expect(location.longitude).to eq( -122.3323955 )
            expect(location.city     ).to eq( 'Seattle'    )
            expect(location.state    ).to eq( 'WA'         )
            expect(location.success  ).to eq( true         )
            expect(location.id       ).to eq( 1            )
        end
      end
    end

    context "with an INvalid input" do
      context "with an invalid zipcode" do
        it "does NOT create a new location" do
          location_count = Location.count
          location.find_or_make_location('9834567')
            expect(Location.count).to eq(location_count) #no change
        end
        it "returns type, latitude, longitude, city, state, success, and id as false or nil" do
          location.find_or_make_location('9834567')
            expect(location.type     ).to eq( nil   )
            expect(location.latitude ).to eq( nil   )
            expect(location.longitude).to eq( nil   )
            expect(location.city     ).to eq( nil   )
            expect(location.state    ).to eq( nil   )
            expect(location.success  ).to eq( false )
            expect(location.id       ).to eq( nil   )
        end
      end
      context "with an invalid city-state" do
        it "does NOT create a new location" do
          location_count = Location.count
          location.find_or_make_location('shuteal, wesh')
            expect(Location.count).to eq(location_count) #no change
        end
        it "returns type, latitude, longitude, city, state, success, and id as false or nil" do
          location.find_or_make_location('paurtelin, oargin')
            expect(location.type     ).to eq( "Place"   )
            expect(location.latitude ).to eq( nil   )
            expect(location.longitude).to eq( nil   )
            expect(location.city     ).to eq( nil   )
            expect(location.state    ).to eq( nil   )
            expect(location.success  ).to eq( false )
            expect(location.id       ).to eq( nil   )
        end
      end
    end
  end
end

