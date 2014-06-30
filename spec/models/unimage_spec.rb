require 'spec_helper'

describe Unimage do

  it { should belong_to(:unpost) }


  describe "unimages_within_limit validation" do
    let!(:jen_unpost) { Fabricate(:unpost) }
    before { 6.times {Fabricate(:unimage, unpost: jen_unpost) } }

    it "limits the maximum number of unimages for an unpost to six" do
      seventh_unimage = jen_unpost.unimages.create(unpost: jen_unpost, filename: '123456789.jpg')
        expect(seventh_unimage.errors).to be_present
        expect(jen_unpost.unimages.reload.size).to eq(6)
    end
  end
end
