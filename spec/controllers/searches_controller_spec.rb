require 'spec_helper'

describe SearchesController, :vcr do
  let!(:settings) { Fabricate(:setting) }

  describe "POST set_search_radius" do
    context "for a Guest or User" do
      context "with a valid numeric radius" do
        before { xhr :post, :set_search_radius, radius: 3 }

        it "should set the session radius to the provided value" do
          expect(session[:search_radius]).to eq(3)
        end
        it "should set the flash success message" do
          expect(flash[:success]).to be_present
        end
        it "should render the js response" do
          expect(response).to render_template 'searches/update_search_radius.js'
        end
      end

      context "with a INVALID radius" do
        before { xhr :post, :set_search_radius, radius: "cool" }

        it "should NOT set the session radius to the provided value" do
          expect(session[:search_radius]).to be_nil
        end
        it "should set the flash success message" do
          expect(flash[:notice]).to be_present
        end
        it "should render the js response" do
          expect(response).to render_template 'searches/update_search_radius.js'
        end
      end
    end

    context "for a User" do
      let!(:jen_town) { Fabricate(:location) }
      let!(:jen)      { Fabricate(:user, location: jen_town) }
      before { spec_signin_user(jen) }

      context "with a valid numeric radius" do
        before { xhr :post, :set_search_radius, radius: 3 }

        it "sets the session radius to the provided value" do
          expect(session[:search_radius]).to eq(3)
        end
        it "sets the user's radius to the new radius" do
          expect(User.first.location.radius).to eq(3)
        end
        it "sets the flash success message" do
          expect(flash[:success]).to be_present
        end
        it "render the js response" do
          expect(response).to render_template 'searches/update_search_radius.js'
        end
      end

      context "with a INVALID radius" do
        before { xhr :post, :set_search_radius, radius: "cool" }

        it "NOT set the session radius to the provided value" do
          expect(session[:search_radius]).to be_nil
        end
        it "sets the user's radius to the new radius" do
          expect(User.first.location.radius).to_not eq("cool")
        end
        it "sets the flash success message" do
          expect(flash[:notice]).to be_present
        end
        it "render the js response" do
          expect(response).to render_template 'searches/update_search_radius.js'
        end
      end
    end
  end


  describe "POST set_search_location" do
    context "for a Guest" do
      context "with a valid zipcode" do
        context "that is NOT already stored in Locations" do
          before do
            Geocoder.should_receive(:search).and_call_original
            xhr :post, :set_search_location, location: 98164
          end

          it "Makes a new location" do
            expect(Location.all.count).to eq(1)
          end
          it "sets the new latitude & longitude values" do
            expect(Location.last.latitude ).to be_present
            expect(Location.last.longitude).to be_present
          end
          it "sets the new location's zipcode to the provided value" do
            expect(Location.last.zipcode).to eq(98164)
          end
          it "sets the session's latitude value to the geocoded latitude" do
            expect(session[:search_latitude]).to eq(47.606503)
          end
          it "sets the session's longitude value to the geocoded longitude" do
            expect(session[:search_longitude]).to eq(-122.3323955)
          end
          it "sets the session's zipcode value to the zipcode provided" do
            expect(session[:search_zipcode]).to eq(98164)
          end
          it "creates a new location" do
            expect(Location.all.count).to eq(1)
          end
          it "sets the flash success message" do
            expect(flash[:success]).to be_present
          end
          it "render the js response" do
            expect(response).to render_template "searches/update_search_location.js"
          end
        end

        context "that IS already stored in Locations" do
          let!(:seattle) { Fabricate(:zip_location) }
          before do
            Geocoder.should_not_receive(:coordinates)
            xhr :post, :set_search_location, location: 98164
          end

          it "does NOT create a new Location in the table" do
            expect(Location.all.count).to eq(1)
          end
          it "sets the session's latitude value to the geocoded latitude" do
            expect(session[:search_latitude]).to eq(47.606503)
          end
          it "sets the session's longitude value to the geocoded longitude" do
            expect(session[:search_longitude]).to eq(-122.3323955)
          end
          it "sets the session's zipcode value to the zipcode provided" do
            expect(session[:search_zipcode]).to eq(98164)
          end
          it "sets the flash success message" do
            expect(flash[:success]).to be_present
          end
          it "render the js response" do
            expect(response).to render_template "searches/update_search_location.js"
          end
        end
      end

      #Note: This could also be a location that reverse_geocodes to city,state
      context "with a valid city,state" do
        context "that is NOT already in Locations database" do
          before do
            Geocoder.should_receive(:search).and_call_original
            xhr :post, :set_search_location, location: "Seattle, WA"
          end

          it "creates a new location" do
            expect(Location.all.count).to eq(1)
          end
          it "sets the new location's latitude & longitude" do
            expect(Location.last.latitude).to eq(47.6062095)
            expect(Location.last.longitude).to eq(-122.3320708)
          end
          it "sets the new location's city in lowercase" do
            expect(Location.last.city).to eq("seattle")
          end
          it "sets the new location's state in lowercase" do
            expect(Location.last.state).to eq("wa")
          end
          it "sets the session's latitude value to the geocoded latitude" do
            expect(session[:search_latitude]).to eq(47.6062095)
          end
          it "sets the session's longitude value to the geocoded longitude" do
            expect(session[:search_longitude]).to eq(-122.3320708)
          end
          it "sets the session's city value to the provided city by reverse geocode" do
            expect(session[:search_city]).to eq("Seattle")
          end
          it "sets the session's state value to the provided city by reverse geocode" do
            expect(session[:search_state]).to eq("WA")
          end
          it "sets the flash success message" do
            expect(flash[:success]).to be_present
          end
          it "render the js response" do
            expect(response).to render_template "searches/update_search_location.js"
          end
        end

        context "that IS already in Locations database" do
          let!(:seattle) { Fabricate(:city_state_location) }
          before do
            Geocoder.should_not_receive(:search)
            xhr :post, :set_search_location, location: "Seattle, WA"
          end

          it "does NOT create a new location" do
            expect(Location.all.count).to eq(1)
          end
          it "sets the session's latitude value to the geocoded latitude" do
            expect(session[:search_latitude]).to eq(47.606503)
          end
          it "sets the session's longitude value to the geocoded longitude" do
            expect(session[:search_longitude]).to eq(-122.3323955)
          end
          it "sets the session's city value to the provided city by reverse geocode" do
            expect(session[:search_city]).to eq("Seattle")
          end
          it "sets the session's state value to the provided city by reverse geocode" do
            expect(session[:search_state]).to eq("WA")
          end
          it "sets the flash success message" do
            expect(flash[:success]).to be_present
          end
          it "render the js response" do
            expect(response).to render_template "searches/update_search_location.js"
          end
        end
      end

      context "with an INVALID location" do
        before do
          Geocoder.should_receive(:search).and_call_original
          xhr :post, :set_search_location, location: "nowhereville, NW"
        end

        it "does NOT create a location" do
          expect(Location.all.count).to eq(0)
        end
        it "does NOT change the session's latitude value" do
          expect(session[:search_latitude]).to eq(nil)
        end
        it "does NOT change the session's longitude value" do
          expect(session[:search_longitude]).to eq(nil)
        end
        it "does NOT change the session's zipcode value" do
          expect(session[:search_zipcode]).to eq(nil)
        end
        it "does NOT change the session's city value" do
          expect(session[:search_city]).to eq(nil)
        end
        it "does NOT change the session's state value" do
          expect(session[:search_state]).to eq(nil)
        end
        it "sets the flash notice message" do
          expect(flash[:notice]).to be_present
        end
        it "renders the js response" do
          expect(response).to render_template "searches/update_search_location.js"
        end
      end
    end

    context "for a User (Users have a default or preset Location)" do
      let!(:jen_town) { Fabricate(:city_state_location      ) }
      let!(:jen)      { Fabricate(:user, location: jen_town ) }

      context "with a valid zipcode" do
        context "that is NOT already stored in Locations" do
          before do
            spec_signin_user(jen)
            Geocoder.should_receive(:search).and_call_original
            xhr :post, :set_search_location, location: 98057
          end

          it "Makes a new location" do
            expect(Location.all.count).to eq(2)
          end
          it "sets the new latitude & longitude values" do
            expect(Location.last.latitude ).to be_present
            expect(Location.last.longitude).to be_present
          end
          it "sets the new location's zipcode to the provided value" do
            expect(Location.last.zipcode).to eq(98057)
          end
          it "sets the session's latitude value to the geocoded latitude" do
            expect(session[:search_latitude]).to eq(47.49427379999999)
          end
          it "sets the session's longitude value to the geocoded longitude" do
            expect(session[:search_longitude]).to eq(-122.2081419)
          end
          it "sets the session's zipcode value to the zipcode provided" do
            expect(session[:search_zipcode]).to eq(98057)
          end
          it "sets the flash success message" do
            expect(flash[:success]).to be_present
          end
          it "render the js response" do
            expect(response).to render_template "searches/update_search_location.js"
          end
        end

        context "that IS already stored in Locations" do
          let!(:seattle) { Fabricate(:zip_location) }
          before do
            Geocoder.should_not_receive(:search)
            xhr :post, :set_search_location, location: 98164
          end

          it "does NOT create a new Location in the table" do
            expect(Location.all.count).to eq(2)
          end
          it "sets the session's latitude value to the geocoded latitude" do
            expect(session[:search_latitude]).to eq(47.606503)
          end
          it "sets the session's longitude value to the geocoded longitude" do
            expect(session[:search_longitude]).to eq(-122.3323955)
          end
          it "sets the session's zipcode value to the zipcode provided" do
            expect(session[:search_zipcode]).to eq(98164)
          end
          it "sets the flash success message" do
            expect(flash[:success]).to be_present
          end
          it "render the js response" do
            expect(response).to render_template "searches/update_search_location.js"
          end
        end
      end

      #Note: This could also be a location that reverse_geocodes to city,state
      context "with a valid city,state" do
        context "that is NOT already in Locations database" do
          before do
            spec_signin_user(jen)
            Geocoder.should_receive(:search).and_call_original
            xhr :post, :set_search_location, location: "Olympia, WA"
          end

          it "creates a new location" do
            expect(Location.all.count).to eq(2)
          end
          it "sets the new location's latitude & longitude" do
            expect(Location.last.latitude).to eq(47.0378741)
            expect(Location.last.longitude).to eq(-122.9006951)
          end
          it "sets the new location's city in lowercase" do
            expect(Location.last.city).to eq("olympia")
          end
          it "sets the new location's state in lowercase" do
            expect(Location.last.state).to eq("wa")
          end
          it "sets the session's latitude value to the geocoded latitude" do
            expect(session[:search_latitude]).to eq(47.0378741)
          end
          it "sets the session's longitude value to the geocoded longitude" do
            expect(session[:search_longitude]).to eq(-122.9006951)
          end
          it "sets the session's city value to the provided city by reverse geocode" do
            expect(session[:search_city]).to eq("Olympia")
          end
          it "sets the session's state value to the provided city by reverse geocode" do
            expect(session[:search_state]).to eq("WA")
          end
          it "sets the flash success message" do
            expect(flash[:success]).to be_present
          end
          it "render the js response" do
            expect(response).to render_template "searches/update_search_location.js"
          end
        end

        context "that IS already in Locations database" do
          before do
            spec_signin_user(jen)
            Geocoder.should_not_receive(:search)
            xhr :post, :set_search_location, location: "Seattle, WA"
          end

          it "does NOT create a new location" do
            expect(Location.all.count).to eq(1)
          end
          it "sets the session's latitude value to the geocoded latitude" do
            expect(session[:search_latitude]).to eq(47.606503)
          end
          it "sets the session's longitude value to the geocoded longitude" do
            expect(session[:search_longitude]).to eq(-122.3323955)
          end
          it "sets the session's city value to the provided city by reverse geocode" do
            expect(session[:search_city]).to eq("Seattle")
          end
          it "sets the session's state value to the provided city by reverse geocode" do
            expect(session[:search_state]).to eq("WA")
          end
          it "sets the flash success message" do
            expect(flash[:success]).to be_present
          end
          it "render the js response" do
            expect(response).to render_template "searches/update_search_location.js"
          end
        end
      end

      context "with an INVALID location" do
        before do
          spec_signin_user(jen)
          Geocoder.should_receive(:search).and_call_original
          xhr :post, :set_search_location, location: "nowhereville, NW"
        end

        it "does NOT create a location" do
          expect(Location.all.count).to eq(1)
        end
        it "does NOT change the session's latitude value" do
          expect(session[:search_latitude]).to eq(nil)
        end
        it "does NOT change the session's longitude value" do
          expect(session[:search_longitude]).to eq(nil)
        end
        it "does NOT change the session's zipcode value" do
          expect(session[:search_zipcode]).to eq(nil)
        end
        it "does NOT change the session's city value" do
          expect(session[:search_city]).to eq(nil)
        end
        it "does NOT change the session's state value" do
          expect(session[:search_state]).to eq(nil)
        end
        it "sets the flash notice message" do
          expect(flash[:notice]).to be_present
        end
        it "renders the js response" do
          expect(response).to render_template "searches/update_search_location.js"
        end
      end
    end
  end
end
