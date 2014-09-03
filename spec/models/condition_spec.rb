require 'spec_helper'

describe Condition do
  let!(:settings) { Fabricate(:setting) }

  it { should belong_to(:category) }
  #it { should have_many(:categories).through(:categories_conditions) }

  it { should validate_presence_of(     :level   ) }
  it { should validate_numericality_of( :position).allow_nil }
  it { should validate_numericality_of( :position).only_integer }
  it { should validate_uniqueness_of(   :position).scoped_to(:category_id) }
  it { should validate_uniqueness_of(   :level   ).scoped_to(:category_id) }

  describe "additional validations" do
    let!(:autos) { Fabricate(:category,  name: 'autos') }
    let!(:games) { Fabricate(:category,  name: 'games') }
    let!(:used)  { Fabricate(:condition, level: 'used', category: autos) }
    context "for two conditions of the same name scoped to different categories" do
      it "the duplicate name associated with a different category is valid" do
        used_car = Condition.new(level: 'used', category: games)
        expect(used_car).to be_valid
      end
    end
  end

  describe "other_conditions_for_category" do
    let!(:games) { Fabricate(:category,  name: 'games') }
    let!(:good)  { Fabricate(:condition, level: 'good', category: games) }
    let!(:okay ) { Fabricate(:condition, level: 'okay', category: games) }
    let!(:fair)  { Fabricate(:condition, level: 'fair', category: games) }
    context "for selection of one category to work with" do
      it "queries all of the other categories except the selected one" do
        others = good.other_conditions_for_category
        expect(others).to include(okay, fair)
      end
    end
  end
end
