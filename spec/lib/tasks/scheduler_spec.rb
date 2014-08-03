require 'spec_helper'
require 'rake'
#require 'rspec/core/rake_task'

describe "scheduler:issue_invitations" do
  let!(:setting)      { Fabricate(:setting) }
  let!(:jen)          { Fabricate(:user, invite_count: 1) }
  let!(:joe)          { Fabricate(:user, invite_count: 4) }
  let(:run_issue_invites) do
    Rake::Task[:issue_invitations].reenable
    Rake.application.invoke_task :issue_invitations
  end

  before do
    Rake.application.rake_require 'tasks/scheduler'
    Rake::Task.define_task(:environment) #rspec runs the App, so dont want Rake to run it AGAIN.
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
