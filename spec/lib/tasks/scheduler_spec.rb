#THIS EXECUTES FINE IN SUBL, BUT FAILS 67, 74, 83 IN CONSOLE
require 'spec_helper'
require 'rake'
require 'sidekiq/testing'
Sidekiq::Testing.inline!


describe "scheduler" do

  describe ":issue_invitations" do
    let!(:setting)      { Fabricate(:setting) }
    let!(:jen)          { Fabricate(:user, invite_count: 1) }
    let!(:joe)          { Fabricate(:user, invite_count: 4) }
    let(:run_issue_invites) do
      Rake::Task[:issue_invitations].reenable
      Rake.application.invoke_task :issue_invitations
    end

    before do
      Rake.application.rake_require 'tasks/scheduler'
      Rake::Task.define_task(:environment) #Stub env. Rspec runs the App, so dont want Rake to run it AGAIN.
    end

    it "should have the 'environment' as a prerequisite" do
      expect(Rake::Task[:issue_invitations].prerequisites).to include("environment")
    end

    context "for a user with full invites" do
      it "adds no additional invites" do
        expect(User.last.invite_count).to eq(4)
        run_issue_invites
        expect(User.last.invite_count).to eq(4)
      end
    end

    context "for a user with less than max invites" do
      it "sets the user's invites to the max value if they are below" do
        expect(User.first.invite_count).to eq(1)
        run_issue_invites
        expect(User.first.invite_count).to eq(4)
      end
    end
  end



  describe ":wipe_abandoned_unimages" do
    let!(:abandoned_old_unimage)   { Fabricate(:unimage) }
    let!(:abandoned_young_unimage) { Fabricate(:unimage) }
    let!(:adopted_unimage)         { Fabricate(:unimage) }
    let(:run_cleaner) do
      Rake::Task[:wipe_abandoned_unimages].reenable
      Rake.application.invoke_task :wipe_abandoned_unimages
    end

    before do
      abandoned_young_unimage.update_columns(unpost_id: nil, updated_at: 6.days.ago)
      abandoned_old_unimage.update_columns(  unpost_id: nil, updated_at: 9.days.ago)
      Rake.application.rake_require 'tasks/scheduler'
      Rake::Task.define_task(:environment) #Stub env. Rspec runs the App, so dont want Rake to run it AGAIN.
    end

    it "should have the 'environment' as a prerequisite" do
      expect(Rake::Task[:wipe_abandoned_unimages].prerequisites).to include("environment")
    end

    context "for abandoned unimages over 1 week old" do
      it "deletes the unimages" do
        run_cleaner
        expect(Unimage.all.count).to eq(2)
      end
    end

    context "for abandoned unimages under 1 week old" do
      it "leaves the unimage" do
        young_id = abandoned_young_unimage.id
        run_cleaner
          expect(Unimage.all.count      ).to eq(2)
          expect(Unimage.find(young_id) ).to be_present
      end
    end

    context "for claimed unimages" do
      it "leaves the unimage" do
        adopted_unimage_id = adopted_unimage.id
        run_cleaner
          expect(Unimage.all.count                ).to eq(2)
          expect(Unimage.find(adopted_unimage_id) ).to be_present
      end
    end
  end
end
