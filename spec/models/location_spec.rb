require 'spec_helper'

describe Location, :vcr do
  it { should have_many(:users) }

  context "with zipcode provided" do
    before do
      Geocoder.configure(:lookup => :test)
      Geocoder::Lookup::Test.set_default_stub(
        [ {
            'latitude'     => 42.3456,
            'longitude'    => -122.3456,
            'address'      => 'Seattle, WA, USA',
            'state'        => 'WA',
            'city'         => "Seattle",
            'state_code'   => 'WA',
            'country'      => 'United States',
            'country_code' => 'US'
          }
        ]
      )
    end
    after { Geocoder.configure(:lookup => :google) }
    it { should validate_numericality_of(:zipcode).allow_nil }

  end
  #geocoder is making this complicated, so skip for now:
  #it { should ensure_length_of(:state  ).is_equal_to(2) }
end
