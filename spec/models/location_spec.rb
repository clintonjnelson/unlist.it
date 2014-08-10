require 'spec_helper'

describe Location, :vcr do

  it { should belong_to(:user) }

  it { should validate_numericality_of(:zipcode).allow_nil      }
  it { should ensure_length_of(        :state  ).is_equal_to(2) }

end
