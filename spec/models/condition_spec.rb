require 'spec_helper'

describe Condition do
  it { should belong_to(:category) }
  #it { should have_many(:categories).through(:categories_conditions) }

  it { should validate_presence_of(     :level) }
  it { should validate_numericality_of( :order).allow_nil }
  it { should validate_numericality_of( :order).only_integer }
  it { should validate_uniqueness_of(   :order).scoped_to(:category_id) }
  it { should validate_uniqueness_of(   :level).scoped_to(:category_id) }

end
