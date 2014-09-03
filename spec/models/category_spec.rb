require 'spec_helper'

describe Category do
  let!(:settings) { Fabricate(:setting) }

  it { should have_many(:conditions).order('position') }
  it { should have_many(:conditions).dependent(:destroy) }

  it { should validate_presence_of(:name) }


  describe "reorder_conditions" do
    context "with direct numbering" do
      let(:autos) { Fabricate(:category, name: "autos") }
      let!(:mint) { Fabricate(:condition, category: autos, position: 1 ) }
      let!(:poor) { Fabricate(:condition, category: autos, position: 4 ) }
      let!(:okay) { Fabricate(:condition, category: autos, position: 3 ) }
      let!(:good) { Fabricate(:condition, category: autos, position: 2 ) }

      it "reorders the conditions from one in their relative order" do
        expect(autos.reorder_conditions).to eq([mint, good, okay, poor])
      end
    end
     context "with relative numbering" do
      let(:autos) { Fabricate(:category, name: "autos") }
      let!(:mint) { Fabricate(:condition, category: autos, position: 10 ) }
      let!(:poor) { Fabricate(:condition, category: autos, position: 44 ) }
      let!(:okay) { Fabricate(:condition, category: autos, position: 35 ) }
      let!(:good) { Fabricate(:condition, category: autos, position: 29 ) }

      it "reorders the conditions from one in their relative order" do
        expect(autos.reorder_conditions).to eq([mint, good, okay, poor])
      end
    end
  end
end
