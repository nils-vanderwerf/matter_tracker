require "rails_helper"

RSpec.describe Matter, type: :model do
  describe "status tracking" do
    it "records the initial status on create" do
      matter = create(:matter, status: "Open")
      expect(matter.status_changes.count).to eq(1)
      expect(matter.status_changes.last.status).to eq("Open")
    end

    describe "#close" do
      it "updates status to Closed and records a status change" do
        matter = create(:matter, status: "Open")
        expect { matter.close }.to change { matter.status_changes.count }.by(1)
        expect(matter.reload.status).to eq("Closed")
        expect(matter.status_changes.order(:created_at).last.status).to eq("Closed")
      end

      it "returns false and records nothing when already closed" do
        matter = create(:matter, status: "Open")
        matter.close
        expect { matter.close }.not_to change { matter.status_changes.count }
      end
    end

    describe "#reopen" do
      it "updates status to Open and records a status change" do
        matter = create(:matter, status: "Open")
        matter.close
        expect { matter.reopen }.to change { matter.status_changes.count }.by(1)
        expect(matter.reload.status).to eq("Open")
        expect(matter.status_changes.order(:created_at).last.status).to eq("Open")
      end

      it "returns false and records nothing when not closed" do
        matter = create(:matter, status: "Open")
        expect { matter.reopen }.not_to change { matter.status_changes.count }
      end
    end

    it "records a status change when status is updated via the edit form" do
      matter = create(:matter, status: "Open")
      expect { matter.update!(status: "Pending") }.to change { matter.status_changes.count }.by(1)
      expect(matter.status_changes.order(:created_at).last.status).to eq("Pending")
    end

    it "does not record a status change when a non-status field is updated" do
      matter = create(:matter, status: "Open")
      expect { matter.update!(title: "New Title") }.not_to change { matter.status_changes.count }
    end
  end

  describe "validations" do
    it "is invalid without a title" do
      matter = build(:matter, title: "")
      expect(matter).not_to be_valid
    end

    it "is invalid with an unrecognised matter_type" do
      matter = build(:matter, matter_type: "Piracy")
      expect(matter).not_to be_valid
    end

    it "is invalid with an unrecognised status" do
      matter = build(:matter, status: "Limbo")
      expect(matter).not_to be_valid
    end
  end

  describe "#overdue?" do
    it "returns true for an open matter with a past due date" do
      matter = create(:matter, status: "Open")
      matter.update_column(:due_date, Date.today - 1)
      expect(matter.overdue?).to be true
    end

    it "returns false for a closed matter with a past due date" do
      matter = create(:matter, status: "Open")
      matter.update_column(:due_date, Date.today - 1)
      matter.close
      expect(matter.overdue?).to be false
    end

    it "returns false when due date is in the future" do
      matter = create(:matter, status: "Open", due_date: Date.today + 7)
      expect(matter.overdue?).to be false
    end

    it "returns false when due date is nil" do
      matter = create(:matter, status: "Open", due_date: nil)
      expect(matter.overdue?).to be false
    end
  end

  describe ".overdue" do
    # Matters become overdue over time — create with a valid date then backdate via
    # update_column to reflect real-world progression without triggering the on: :create validation.

    it "includes open matters with a past due date" do
      matter = create(:matter, status: "Open")
      matter.update_column(:due_date, Date.today - 1)
      expect(Matter.overdue).to include(matter)
    end

    it "includes pending matters with a past due date" do
      matter = create(:matter, status: "Pending")
      matter.update_column(:due_date, Date.today - 1)
      expect(Matter.overdue).to include(matter)
    end

    it "excludes closed matters even with a past due date" do
      matter = create(:matter, status: "Open")
      matter.update_column(:due_date, Date.today - 1)
      matter.close
      expect(Matter.overdue).not_to include(matter)
    end

    it "excludes matters with a future due date" do
      matter = create(:matter, status: "Open", due_date: Date.today + 7)
      expect(Matter.overdue).not_to include(matter)
    end

    it "excludes matters with no due date" do
      matter = create(:matter, status: "Open", due_date: nil)
      expect(Matter.overdue).not_to include(matter)
    end
  end

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
