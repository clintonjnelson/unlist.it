require 'spec_helper'
require 'carrierwave/test/matchers'

describe AvatarUploader do
  include CarrierWave::Test::Matchers
  let!(:joe_user) { Fabricate(:user) }
  before do
    AvatarUploader.enable_processing = true
      @avatar = AvatarUploader.new(joe_user, :avatar)
      @avatar.store!(File.open("#{Rails.root}/spec/support/uploads/test.png"))
  end
  after do
    AvatarUploader.enable_processing = false
    @avatar.remove!
  end

  context "it saves the png file as jpg format" do
    it "saves the original in its original format" do
      expect(@avatar.file.extension).to eq('jpg')
    end
    it "saves the subsequent versions as 'jpg' format" do
      expect(@avatar.thumb_avatar.file.extension  ).to eq('jpg')
      expect(@avatar.medium_avatar.file.extension ).to eq('jpg')
      expect(@avatar.large_avatar.file.extension  ).to eq('jpg')
    end
  end

  context "picture upload version" do
    it "scales the thumbnail avatar picture down to 35 x __" do
      expect(@avatar.thumb_avatar).to have_dimensions(35,22)
    end
    it "scales the medium avatar picture down to 60 x __" do
      expect(@avatar.medium_avatar).to have_dimensions(60,38)
    end
    it "scales the large avatar picture down to 150 x __" do
      expect(@avatar.large_avatar).to have_dimensions(150,94)
    end
  end
end
