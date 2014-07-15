require 'spec_helper'

describe UserDecorator do

  describe "for a user without avatar" do
    let!(:jen) { Fabricate(:user) }

    it "should return a gravatar image to the user" do
      gravatar = UserDecorator.new(jen).avatar_image_tag
      expect(gravatar).to include("https://secure.gravatar.com/avatar/")
    end
  end


  describe "for a user with avatar" do
    let!(:jen) { Fabricate(:user, avatar: "1234", use_avatar: true) }
    before { UserDecorator.any_instance.should_receive(:avatar_image).and_return("/support/uploads/test.png") }

    it "should return a gravatar image to the user" do
      avatar = UserDecorator.new(jen).avatar_image_tag
      expect(avatar).to include("/support/uploads/test.png")
    end
  end
end
