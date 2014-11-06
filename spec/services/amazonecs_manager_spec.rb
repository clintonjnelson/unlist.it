require 'spec_helper'

describe AmazonecsManager, :vcr do
  let!(:settings)    { Fabricate(:setting) }
  let!(:valid_url)   { "http://www.amazon.com/Intelligent-Investor-Definitive-Investing-Essentials/dp/0060555661/ref=sr_1_1?s=books&ie=UTF8&qid=1415080695&sr=1-1&keywords=intelligent+investor" }
  let!(:invalid_url) { "www.notamazon.com" }

  describe "asin_from_url" do
    context "for valid amazon URLs" do
      it "returns the ASIN" do
        ecs = AmazonecsManager.new(url: valid_url)
        asin = ecs.asin_from_url
          expect(asin).to eq("0060555661")
      end
    end

    context "for invalid URLs" do
      it "returns nil" do
        ecs = AmazonecsManager.new(url: invalid_url)
        asin = ecs.asin_from_url
          expect(asin).to be_nil
      end
    end
  end



  describe "raw amazon_link" do
    context "with valid url" do
      it "returns a simple dp/asin link" do
        ecs = AmazonecsManager.new(url: valid_url)
        link = ecs.amazon_link
          expect(link).to eq("http://www.amazon.com/dp/0060555661")
      end
    end

    context "with invalid url" do
      it "returns nil" do
        ecs = AmazonecsManager.new(url: invalid_url)
        link = ecs.amazon_link
          expect(link).to be_nil
      end
    end

    context "with valid asin" do
      it "returns a simple dp/asin link" do
        ecs = AmazonecsManager.new(asin: "0060555661")
        link = ecs.amazon_link
          expect(link).to eq("http://www.amazon.com/dp/0060555661")
      end
    end

    context "with invalid asin" do
      it "returns nil" do
        ecs = AmazonecsManager.new(asin: "fjkfjkfjkfjkfjkf")
        link = ecs.amazon_link
          expect(link).to be_nil
      end
    end
  end




  describe "get_product_image" do
    context "with valid url" do
      it "returns the product image link" do
        ecs = AmazonecsManager.new(url: valid_url)
        image_url = ecs.get_product_image
          expect(image_url).to eq("http://ecx.images-amazon.com/images/I/41UBQMp2B6L.jpg")
      end
    end

    context "with invalid url" do
      it "returns nil" do
        ecs = AmazonecsManager.new(url: invalid_url)
        image_url = ecs.get_product_image
          expect(image_url).to be_nil
      end
    end

    context "with valid asin" do
      it "returns a simple dp/asin link" do
        ecs = AmazonecsManager.new(asin: "0060555661")
        image_url = ecs.get_product_image
          expect(image_url).to eq("http://ecx.images-amazon.com/images/I/41UBQMp2B6L.jpg")
      end
    end

    context "with invalid asin" do
      it "returns nil" do
        ecs = AmazonecsManager.new(asin: "fjkfjkfjkfjkfjkf")
        image_url = ecs.get_product_image
          expect(image_url).to be_nil
      end
    end
  end
end

