require "rails_helper"

RSpec.describe Task, type: :model do
  let(:matter) { create(:matter) }

  describe "validations" do
    it "is valid with a title and matter" do
      task = build(:task, matter: matter)
      expect(task).to be_valid
    end

    it "is invalid without a title" do
      task = build(:task, matter: matter, title: "")
      expect(task).not_to be_valid
    end

    it "is valid with a valid status" do
      task = build(:task, matter: matter, status: "Pending")
      expect(task).to be_valid
    end

    it "is invalid with an invalid status" do
      task = build(:task, matter: matter, status: "Banana")
      expect(task).not_to be_valid
    end

    it "is valid with a valid priority" do
      task = build(:task, matter: matter, priority: "High")
      expect(task).to be_valid
    end

    it "is invalid with an invalid priority" do
      task = build(:task, matter: matter, priority: "Extreme")
      expect(task).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to its matter" do
      task = build(:task, matter: matter)
      expect(task.matter).to eq(matter)
    end
  end

  describe "#overdue?" do
    it "returns true for an incomplete task with a past due date" do
      task = create(:task, matter: matter, status: "Pending", due_date: Date.today - 1)
      expect(task.overdue?).to be true
    end

    it "returns false for a completed task with a past due date" do
      task = create(:task, matter: matter, status: "Completed", due_date: Date.today - 1)
      expect(task.overdue?).to be false
    end

    it "returns false when due date is in the future" do
      task = create(:task, matter: matter, status: "Pending", due_date: Date.today + 7)
      expect(task.overdue?).to be false
    end

    it "returns false when due date is nil" do
      task = create(:task, matter: matter, status: "Pending", due_date: nil)
      expect(task.overdue?).to be false
    end
  end

  describe "scopes" do
    describe "status" do
      it "returns only pending tasks" do
        brushing_teeth = create(:task, matter: matter, title: "Brushing Teeth", status: "Pending")
        washing_face   = create(:task, matter: matter, title: "Washing Face", status: "Pending")
        feeding_cats   = create(:task, matter: matter, title: "Feeding Cats", status: "In Progress")
        having_lunch   = create(:task, matter: matter, title: "Having Lunch", status: "Completed")

        expect(Task.pending).to eq([brushing_teeth, washing_face])
      end
    end

    describe "priority" do
      it "returns only high priority tasks" do
        eating_pizza   = create(:task, matter: matter, title: "Eating Pizza", priority: "High")
        washing_hands  = create(:task, matter: matter, title: "Washing Hands", priority: "Medium")
        calling_mother = create(:task, matter: matter, title: "Calling Mother", priority: "Low")

        expect(Task.high_priority).to eq([eating_pizza])
      end
    end

    describe ".overdue" do
      it "includes incomplete tasks with a past due date" do
        task = create(:task, matter: matter, status: "Pending", due_date: Date.today - 1)
        expect(Task.overdue).to include(task)
      end

      it "includes in-progress tasks with a past due date" do
        task = create(:task, matter: matter, status: "In Progress", due_date: Date.today - 1)
        expect(Task.overdue).to include(task)
      end

      it "excludes completed tasks even with a past due date" do
        task = create(:task, matter: matter, status: "Completed", due_date: Date.today - 1)
        expect(Task.overdue).not_to include(task)
      end

      it "excludes tasks with a future due date" do
        task = create(:task, matter: matter, status: "Pending", due_date: Date.today + 7)
        expect(Task.overdue).not_to include(task)
      end

      it "excludes tasks with no due date" do
        task = create(:task, matter: matter, status: "Pending", due_date: nil)
        expect(Task.overdue).not_to include(task)
      end
    end
  end
end
