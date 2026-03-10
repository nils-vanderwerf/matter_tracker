require "rails_helper"

RSpec.describe MatterStatusChange, type: :model do
  describe "associations" do
    it "belongs to a matter" do
      change = build(:matter_status_change)
      expect(change.matter).to be_a(Matter)
    end
  end

  describe "creation" do
    it "records the status and timestamp" do
      matter = create(:matter)
      change = matter.status_changes.last
      expect(change.status).to eq("Open")
      expect(change.created_at).to be_within(2.seconds).of(Time.current)
    end

    it "persists multiple changes in order" do
      matter = create(:matter)
      matter.close
      matter.reopen

      statuses = matter.status_changes.order(:created_at).pluck(:status)
      expect(statuses).to eq(%w[Open Closed Open])
    end
  end
end
