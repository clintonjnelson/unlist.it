require 'spec_helper'
require 'carrierwave/test/matchers'

describe UnimageUploader, :vcr do
  let!(:settings) { Fabricate(:setting) }

  include CarrierWave::Test::Matchers
  let!(:unimage) { Fabricate(:unimage) }
  before do
    UnimageUploader.enable_processing = true
      @unimage = UnimageUploader.new(unimage, :filename)
      @unimage.store!(File.open("#{Rails.root}/spec/support/uploads/test.png"))
  end
  after do
    UnimageUploader.enable_processing = false
    @unimage.remove!
  end

  context "it saves the png file as jpg format" do
    it "saves the original in its original format" do
      expect(@unimage.file.extension).to eq('jpg')
    end
    it "saves the subsequent versions as 'jpg' format" do
      expect(@unimage.thumb_unimage.file.extension ).to eq('jpg')
      expect(@unimage.full_unimage.file.extension  ).to eq('jpg')
    end
  end

  context "picture upload version" do
    it "scales the thumbnail unimage picture down to 120 x __" do
      expect(@unimage.thumb_unimage).to have_dimensions(120,75)
    end
    it "scales the medium unimage picture to 500 x __" do
      expect(@unimage.full_unimage).to have_dimensions(500,313)
    end
  end
end
