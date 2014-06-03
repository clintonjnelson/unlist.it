require 'spec_helper'

describe Category do
  it { should have_many(:conditions).order('position') }
  #it { should have_many(:conditions).through(:categories_conditions) }
end
