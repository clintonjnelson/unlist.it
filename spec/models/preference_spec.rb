require 'spec_helper'

describe Preference do
  it { should belong_to(:user) }


  describe "set_initial_values" do
    before { Preference.create }
    it "sets the hit_notifications to true" do
      expect(Preference.first.hit_notifications).to be_true
    end
    it "sets the safeguest_contact to true" do
      expect(Preference.first.safeguest_contact).to be_true
    end
  end
end
