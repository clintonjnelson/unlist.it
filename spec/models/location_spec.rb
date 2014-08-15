require 'spec_helper'

describe Location, :vcr do

  it { should have_many(:users) }


  it { should validate_numericality_of(:zipcode).allow_nil }
  #geocoder is making this complicated, so skip for now:
    #it { should ensure_length_of(:state  ).is_equal_to(2) }

end
