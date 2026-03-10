require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /" do
    it "returns 200" do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "overdue matters section" do
    # Matters become overdue over time — backdate via update_column to avoid the on: :create validation.

    it "shows matters that are past their due date and not closed" do
      matter = create(:matter, title: "Overdue Matter", status: "Open")
      matter.update_column(:due_date, Date.today - 1)
      get dashboard_path
      expect(response.body).to include("Overdue Matter")
    end

    it "does not show closed matters even with a past due date" do
      matter = create(:matter, title: "Old Closed Matter", status: "Open")
      matter.update_column(:due_date, Date.today - 1)
      matter.close
      get dashboard_path
      expect(response.body).not_to include("Old Closed Matter")
    end

    it "does not show matters with a future due date" do
      create(:matter, title: "Future Matter", due_date: Date.today + 30)
      get dashboard_path
      within_overdue = response.body.match(/Overdue Matters.*?Upcoming Deadlines/m)&.to_s || ""
      expect(within_overdue).not_to include("Future Matter")
    end
  end

  describe "upcoming deadlines section" do
    it "shows open matters due within 14 days" do
      create(:matter, title: "Upcoming Matter", status: "Open", due_date: Date.today + 7)
      get dashboard_path
      expect(response.body).to include("Upcoming Matter")
    end

    it "does not show matters due beyond 14 days" do
      create(:matter, title: "Far Future Matter", due_date: Date.today + 30)
      get dashboard_path
      within_upcoming = response.body.match(/Upcoming Deadlines.*?High Priority Tasks/m)&.to_s || ""
      expect(within_upcoming).not_to include("Far Future Matter")
    end

    it "does not show closed matters" do
      matter = create(:matter, title: "Closed Upcoming", status: "Open", due_date: Date.today + 5)
      matter.close
      get dashboard_path
      within_upcoming = response.body.match(/Upcoming Deadlines.*?High Priority Tasks/m)&.to_s || ""
      expect(within_upcoming).not_to include("Closed Upcoming")
    end
  end

  describe "high priority tasks section" do
    it "shows incomplete high priority tasks" do
      matter = create(:matter)
      create(:task, title: "Urgent Task", matter: matter, priority: "High", status: "Pending")
      get dashboard_path
      expect(response.body).to include("Urgent Task")
    end

    it "does not show completed high priority tasks" do
      matter = create(:matter)
      create(:task, title: "Done Task", matter: matter, priority: "High", status: "Completed")
      get dashboard_path
      expect(response.body).not_to include("Done Task")
    end

    it "does not show incomplete low priority tasks" do
      matter = create(:matter)
      create(:task, title: "Low Task", matter: matter, priority: "Low", status: "Pending")
      get dashboard_path
      within_tasks = response.body.match(/High Priority Tasks.*/m)&.to_s || ""
      expect(within_tasks).not_to include("Low Task")
    end
  end

  describe "stat cards" do
    it "displays all four stat card labels" do
      get dashboard_path
      expect(response.body).to include("Open Matters")
      expect(response.body).to include("Pending Matters")
      expect(response.body).to include("Overdue Matters")
      expect(response.body).to include("Overdue Tasks")
    end

    it "counts overdue tasks correctly" do
      matter = create(:matter)
      create(:task, matter: matter, status: "Pending", due_date: Date.today - 1)
      create(:task, matter: matter, status: "Completed", due_date: Date.today - 1)
      get dashboard_path
      # 1 overdue (completed one excluded), rendered somewhere in the body near "Overdue Tasks"
      expect(response.body).to match(/1\s*<\/div>\s*<div class="stat-label">Overdue Tasks/)
    end
  end
end
