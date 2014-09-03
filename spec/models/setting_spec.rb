require 'spec_helper'

describe Setting do
  let!(:settings) { Fabricate(:setting) }


  it { should validate_numericality_of(:invites_max   ).only_integer }
  it { should validate_numericality_of(:invites_ration).only_integer }

end
