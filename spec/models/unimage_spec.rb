require 'spec_helper'

describe Unimage do

  it { should belong_to(:unlisting) }


  describe "unimages_within_limit validation", :vcr do
    let!(:jen_unlisting) { Fabricate(:unlisting) }
    before { 6.times {Fabricate(:unimage, unlisting: jen_unlisting) } }

    it "limits the maximum number of unimages for an unlisting to six" do
      seventh_unimage = jen_unlisting.unimages.create(unlisting: jen_unlisting, filename: '123456789.jpg')
        expect(seventh_unimage.errors).to be_present
        expect(jen_unlisting.unimages.reload.size).to eq(6)
    end
  end
end
