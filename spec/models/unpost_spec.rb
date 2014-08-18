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

  #it { should accept_nested_attributes_for(:unimages).allow_destroy(true) }


  describe "parent_messages" do
    context "for an unpost parent message with replies" do
      let!(:jen_unpost)               { Fabricate(:unpost) }
      let!(:active_parent_msg)        { Fabricate(:user_unpost_message) }
      let!(:deleted_parent_msg)       { Fabricate(:user_unpost_message, deleted_at: Time.now) }

      it "returns only the active parent message" do
        expect(jen_unpost.parent_messages).to eq([active_parent_msg])
      end
    end
  end

  describe "slugging" do
    let!(:jen_unpost) { Fabricate(:unpost, title: "Toyota Corolla GTS") }
    context "for a new unpost with unique title" do
      it "generates a slug for the unpost" do
        expect(Unpost.last.slug).to be_present
      end
      it "makes the slug from the new unpost title using dashes for spaces" do
        expect(Unpost.last.slug).to eq("toyota-corolla-gts")
      end
    end
    context "for a new unpost with once-prior used title" do
      it "adds a number identifier to the end of the unpost with same title" do
        similar_unpost = Fabricate(:unpost, title: "Toyota Corolla GTS")
        expect(Unpost.last.slug).to eq('toyota-corolla-gts-2')
      end
    end
  end

  describe "the assocated unimages_within_limit validation" do
    let!(:jen_unpost) { Fabricate(:unpost) }
    before { 6.times  { Fabricate(:unimage, unpost: jen_unpost) } }

    it "limits the maximum number of unimages for an unpost to six" do
      seventh_unimage = jen_unpost.unimages.create(unpost: jen_unpost, filename: '123456789.jpg')
        expect(seventh_unimage.errors).to be_present
        expect(jen_unpost.unimages.reload.size).to eq(6)
    end
  end

  describe "delete_correspondence" do
    let!(:jen_unpost)     { Fabricate(:unpost) }

    context "with a parent & reply message" do
      let!(:parent_message) { Fabricate(:user_unpost_message) }
      let!(:reply_message ) { Fabricate(:reply_message) }

      it "deletes all parent & reply messages associated with unpost" do
        jen_unpost.delete_correspondence
          expect(parent_message.reload.deleted_at).to be_present
          expect( reply_message.reload.deleted_at).to be_present
      end
    end
    context "without a parent or reply message" do
      it "should not raise any errors for not having associated messages" do
        expect{jen_unpost.delete_correspondence}.not_to raise_error
      end
    end
  end

  # describe "filter_dollar_symbols_from_price callback" do
  #   context "for price with dollar-sign in it" do
  #     it "edits out the dollar sign" do
  #       unpost = Fabricate.build(:unpost, price: "$30")
  #       unpost.save
  #         expect(unpost.price).to eq(30)
  #         expect(unpost.errors).to_not be_present
  #     end
  #   end
  #   context "for price with dollar-sign in it" do

  #   end
  # end
end
