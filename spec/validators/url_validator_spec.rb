require 'spec_helper'

describe UrlValidator, :vcr do

  context "for a valid URL" do
    subject do
      Test = Class.new do
        include ActiveModel::Validations
        attr_accessor :link
        validates :link, url: true
      end
      Test.new
    end

    it "does NOT raise an error" do
      subject.link = 'http://www.google.com'
      subject.valid?
      expect(subject.errors.full_messages).to eq []
    end
    it "will hit a complex amazon url" do
      subject.link = "http://www.amazon.com/BABYBJORN-Travel-Crib-Light-Silver/dp/B005EWF4BY/ref=sr_1_2?ie=UTF8&qid=1409544080&sr=8-2&keywords=babybjorn+travel+crib"
      subject.valid?
      expect(subject.errors.full_messages).to eq []
    end
  end

  context "for an invalid URL" do
    ['http:/www.google.com', 'https://google' ,'https://google@com', '<>hi'].each do |invalid_url|
      subject do
        Test = Class.new do
          include ActiveModel::Validations
          attr_accessor :link
          validates :link, url: true
        end
        Test.new
      end

      it "#{invalid_url.inspect} raises an error" do
        subject.link = invalid_url
        subject.valid?
        expect(subject.errors).to be_present
        expect(subject.errors.messages[:link]).to be_present
      end
    end
  end
end


