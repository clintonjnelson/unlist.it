require 'spec_helper'
require 'sidekiq/testing'
require 'carrierwave/test/matchers'
Sidekiq::Testing.fake!

describe UnimagesCleaner do
  let(:unlisting)   { Fabricate(:unlisting) }
  let!(:unimage) { Fabricate(:unimage, unlisting_id: unlisting.id) }

  include CarrierWave::Test::Matchers
  before do
    UnimageUploader.enable_processing = true
    @unimage = UnimageUploader.new(unimage, :filename)
    @unimage.store!(File.open("#{Rails.root}/spec/support/uploads/test.png"))
  end
  after do
    UnimageUploader.enable_processing = false
    @unimage.remove!
  end

  #### TWO TESTS DON"T YET WORK. **MUST RUN FROM CONSOLE.
  describe "process" do
    it "queues the process" #do
    #   unimage_id = [unimage.id]
    #   UnimagesCleaner.perform_in(1.day, unimage_id)
    #   expect(Sidekiq::Extensions::DelayedModel.jobs.size).to eq(1)
    # end
    it "sets the unlisting filename reference to nil" do
      unimage_id = [unimage.id]
      UnimagesCleaner.perform_async(unimage_id)
      expect(Unimage.first.filename.filename).to be_nil
    end
    it "deletes the unimage image file" #do
    #   unimage_id = [unimage.id]
    #   filepath = Unimage.first.filename.current_path
    #   UnimagesCleaner.perform_async(unimage_id)
    #   expect(File.exist?(filepath)).to be_false
    # end
  end
end
