require 'spec_helper'

describe Unpost do
  it { should belong_to(:creator        ).with_foreign_key(:user_id) }
  it { should belong_to(:category       ) }
  it { should belong_to(:condition      ) }
  it { should have_many(:unimages       ) }

  it { should validate_presence_of(:title       ) }
  it { should validate_presence_of(:description ) }
  it { should validate_presence_of(:condition_id) }
  it { should validate_presence_of(:category_id ) }
  it { should validate_presence_of(:keyword1    ) }
  it { should validate_presence_of(:user_id     ) }
 #it { should validate_presence_of(:travel      ) }

  it { should validate_numericality_of(:price   ).only_integer }
 #it { should validate_numericality_of(:distance).only_integer }
 #it { should validate_numericality_of(:zipcode ).only_integer }

 #it { should allow_value("", nil).for(:distance) }
  it { should allow_value("", nil).for(:keyword2) }
  it { should allow_value("", nil).for(:keyword3) }
  it { should allow_value("", nil).for(:keyword4) }
  it { should allow_value("", nil).for(:link    ) }

  it { should accept_nested_attributes_for(:unimages).allow_destroy(true) }



  describe "the assocated unimages_within_limit validation" do
    let!(:jen_unpost) { Fabricate(:unpost) }
    before { 6.times {Fabricate(:unimage, unpost: jen_unpost) } }

    it "limits the maximum number of unimages for an unpost to six" do
      seventh_unimage = jen_unpost.unimages.create(unpost: jen_unpost, filename: '123456789.jpg')
        expect(seventh_unimage.errors).to be_present
        expect(jen_unpost.unimages.reload.size).to eq(6)
    end
  end
end
