require 'spec_helper'

describe Condition do
  it { should have_many(:categories_conditions) }
  it { should have_many(:categories).through(:categories_conditions) }
end
