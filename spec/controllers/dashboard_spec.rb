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

  describe "filtering" do
    describe "matter_type filter" do
      it "shows only matters of the selected type in the overdue section" do
        family = create(:matter, title: "Family Matter", matter_type: "Family Law")
        criminal = create(:matter, title: "Criminal Matter", matter_type: "Criminal")
        family.update_column(:due_date, Date.today - 1)
        criminal.update_column(:due_date, Date.today - 1)

        get dashboard_path, params: { matter_type: "Family Law" }

        within_overdue = response.body.match(/Overdue Matters.*?Upcoming Deadlines/m)&.to_s || ""
        expect(within_overdue).to include("Family Matter")
        expect(within_overdue).not_to include("Criminal Matter")
      end

      it "shows only matters of the selected type in the upcoming section" do
        family = create(:matter, title: "Family Upcoming", matter_type: "Family Law", due_date: Date.today + 5)
        commercial = create(:matter, title: "Commercial Upcoming", matter_type: "Commercial", due_date: Date.today + 5)

        get dashboard_path, params: { matter_type: "Family Law" }

        within_upcoming = response.body.match(/Upcoming Deadlines.*?High Priority Tasks/m)&.to_s || ""
        expect(within_upcoming).to include("Family Upcoming")
        expect(within_upcoming).not_to include("Commercial Upcoming")
      end

      it "shows a filter tag on matter section headers when active" do
        get dashboard_path, params: { matter_type: "Commercial" }
        expect(response.body).to include("Commercial")
      end

      it "does not filter the stat card counts" do
        create(:matter, status: "Open", matter_type: "Family Law", due_date: Date.today + 10)
        create(:matter, status: "Open", matter_type: "Criminal", due_date: Date.today + 10)

        get dashboard_path, params: { matter_type: "Family Law" }

        expect(response.body).to match(/2\s*<\/div>\s*<div class="stat-label">Open Matters/)
      end
    end

    describe "task_status filter" do
      it "shows only tasks with the selected status" do
        matter = create(:matter)
        create(:task, title: "Pending Task", matter: matter, priority: "High", status: "Pending")
        create(:task, title: "In Progress Task", matter: matter, priority: "High", status: "In Progress")

        get dashboard_path, params: { task_status: "Pending" }

        within_tasks = response.body.match(/High Priority Tasks.*/m)&.to_s || ""
        expect(within_tasks).to include("Pending Task")
        expect(within_tasks).not_to include("In Progress Task")
      end
    end

    it "shows a Clear link when any filter is active" do
      get dashboard_path, params: { matter_type: "Criminal" }
      expect(response.body).to include("Clear")
    end

    it "does not show a Clear link with no filters" do
      get dashboard_path
      expect(response.body).not_to include(">Clear<")
    end
  end

  describe "sorting" do
    describe "matters sort" do
      it "defaults to sorting by due_date ascending" do
        sooner = create(:matter, title: "Due Sooner")
        later  = create(:matter, title: "Due Later")
        sooner.update_column(:due_date, Date.today - 2)
        later.update_column(:due_date,  Date.today - 1)

        get dashboard_path
        within_overdue = response.body.match(/Overdue Matters.*?Upcoming Deadlines/m)&.to_s || ""
        expect(within_overdue.index("Due Sooner")).to be < within_overdue.index("Due Later")
      end

      it "sorts by title ascending" do
        alpha  = create(:matter, title: "Alpha Matter")
        zebra  = create(:matter, title: "Zebra Matter")
        alpha.update_column(:due_date, Date.today - 1)
        zebra.update_column(:due_date, Date.today - 1)

        get dashboard_path, params: { matters_sort: "title", matters_dir: "asc" }
        within_overdue = response.body.match(/Overdue Matters.*?Upcoming Deadlines/m)&.to_s || ""
        expect(within_overdue.index("Alpha Matter")).to be < within_overdue.index("Zebra Matter")
      end

      it "sorts by title descending" do
        alpha = create(:matter, title: "Alpha Matter")
        zebra = create(:matter, title: "Zebra Matter")
        alpha.update_column(:due_date, Date.today - 1)
        zebra.update_column(:due_date, Date.today - 1)

        get dashboard_path, params: { matters_sort: "title", matters_dir: "desc" }
        within_overdue = response.body.match(/Overdue Matters.*?Upcoming Deadlines/m)&.to_s || ""
        expect(within_overdue.index("Zebra Matter")).to be < within_overdue.index("Alpha Matter")
      end

      it "sorts by client name" do
        client_a = create(:client, name: "Aardvark Corp")
        client_z = create(:client, name: "Zephyr Ltd")
        m1 = create(:matter, title: "Matter One",   client: client_z)
        m2 = create(:matter, title: "Matter Two",   client: client_a)
        m1.update_column(:due_date, Date.today - 1)
        m2.update_column(:due_date, Date.today - 1)

        get dashboard_path, params: { matters_sort: "client", matters_dir: "asc" }
        within_overdue = response.body.match(/Overdue Matters.*?Upcoming Deadlines/m)&.to_s || ""
        expect(within_overdue.index("Matter Two")).to be < within_overdue.index("Matter One")
      end

      it "shows ↑ on the active column header when ascending" do
        m = create(:matter, title: "Some Matter")
        m.update_column(:due_date, Date.today - 1)
        get dashboard_path, params: { matters_sort: "title", matters_dir: "asc" }
        expect(response.body).to include("Matter ↑")
      end

      it "shows ↓ on the active column header when descending" do
        m = create(:matter, title: "Some Matter")
        m.update_column(:due_date, Date.today - 1)
        get dashboard_path, params: { matters_sort: "title", matters_dir: "desc" }
        expect(response.body).to include("Matter ↓")
      end

      it "marks the active column with sort-active class" do
        m = create(:matter, title: "Some Matter")
        m.update_column(:due_date, Date.today - 1)
        get dashboard_path, params: { matters_sort: "title" }
        expect(response.body).to include('class="sort-active"')
      end

      it "does not crash on an unrecognised sort column" do
        get dashboard_path, params: { matters_sort: "'; DROP TABLE matters;--" }
        expect(response).to have_http_status(:ok)
      end
    end

    describe "tasks sort" do
      let(:matter) { create(:matter) }

      it "sorts by title ascending" do
        create(:task, title: "Alpha Task", matter: matter, priority: "High", status: "Pending")
        create(:task, title: "Zebra Task", matter: matter, priority: "High", status: "Pending")

        get dashboard_path, params: { tasks_sort: "title", tasks_dir: "asc" }
        within_tasks = response.body.match(/High Priority Tasks.*/m)&.to_s || ""
        expect(within_tasks.index("Alpha Task")).to be < within_tasks.index("Zebra Task")
      end

      it "sorts by title descending" do
        create(:task, title: "Alpha Task", matter: matter, priority: "High", status: "Pending")
        create(:task, title: "Zebra Task", matter: matter, priority: "High", status: "Pending")

        get dashboard_path, params: { tasks_sort: "title", tasks_dir: "desc" }
        within_tasks = response.body.match(/High Priority Tasks.*/m)&.to_s || ""
        expect(within_tasks.index("Zebra Task")).to be < within_tasks.index("Alpha Task")
      end

      it "sorts by matter title" do
        matter_a = create(:matter, title: "Alpha Matter")
        matter_z = create(:matter, title: "Zebra Matter")
        create(:task, title: "Task for Z", matter: matter_z, priority: "High", status: "Pending")
        create(:task, title: "Task for A", matter: matter_a, priority: "High", status: "Pending")

        get dashboard_path, params: { tasks_sort: "matter", tasks_dir: "asc" }
        within_tasks = response.body.match(/High Priority Tasks.*/m)&.to_s || ""
        expect(within_tasks.index("Task for A")).to be < within_tasks.index("Task for Z")
      end

      it "shows ↑ on the active tasks column header when ascending" do
        create(:task, title: "Some Task", matter: matter, priority: "High", status: "Pending")
        get dashboard_path, params: { tasks_sort: "title", tasks_dir: "asc" }
        expect(response.body).to include("Task ↑")
      end

      it "does not crash on an unrecognised tasks sort column" do
        get dashboard_path, params: { tasks_sort: "'; DROP TABLE tasks;--" }
        expect(response).to have_http_status(:ok)
      end
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
