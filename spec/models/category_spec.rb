require 'spec_helper'

describe Category do
  it { should have_many(:categories_conditions) }
  it { should have_many(:conditions).through(:categories_conditions) }
end
