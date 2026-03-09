require "rails_helper"

RSpec.describe Matter, type: :model do
  describe "due_date validation on create" do
    it "is valid with a due date today" do
      matter = build(:matter, due_date: Date.today)
      expect(matter).to be_valid
    end

    it "is valid with a due date in the future" do
      matter = build(:matter, due_date: Date.today + 30)
      expect(matter).to be_valid
    end

    it "is invalid with a due date in the past" do
      matter = build(:matter, due_date: Date.today - 1)
      expect(matter).not_to be_valid
      expect(matter.errors[:due_date]).to include("must be today or in the future")
    end

    it "is valid with no due date" do
      matter = build(:matter, due_date: nil)
      expect(matter).to be_valid
    end

    it "allows a past due date when updating an existing record" do
      matter = create(:matter, due_date: Date.today + 1)
      matter.due_date = Date.today - 5
      expect(matter).to be_valid
    end
  end
end
