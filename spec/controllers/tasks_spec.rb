require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let(:matter) { create(:matter) }
  let(:task)   { create(:task, matter: matter) }

  describe "GET /tasks/:id" do
    it "returns 200" do
      get task_path(task)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /matters/:matter_id/tasks/new" do
    it "returns 200" do
      get new_matter_task_path(matter)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /matters/:matter_id/tasks" do
    context "with valid params" do
      it "creates a task and redirects to the matter" do
        expect {
          post matter_tasks_path(matter), params: {
            task: { title: "File documents", status: "Pending", priority: "High" }
          }
        }.to change(Task, :count).by(1)

        expect(response).to redirect_to(matter_path(matter))
      end
    end

    context "with invalid params" do
      it "does not create a task and re-renders the form" do
        expect {
          post matter_tasks_path(matter), params: {
            task: { title: "", status: "Pending", priority: "High" }
          }
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /tasks/:id/edit" do
    it "returns 200" do
      get edit_task_path(task)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /tasks/:id" do
    context "with valid params" do
      it "updates the task and redirects to the matter" do
        patch task_path(task), params: { task: { title: "Updated task" } }
        expect(response).to redirect_to(matter_path(matter))
        expect(task.reload.title).to eq("Updated task")
      end
    end

    context "with invalid params" do
      it "re-renders the form" do
        patch task_path(task), params: { task: { title: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /tasks/:id" do
    it "destroys the task and redirects to the matter" do
      task # create it
      expect {
        delete task_path(task)
      }.to change(Task, :count).by(-1)

      expect(response).to redirect_to(matter_path(matter))
    end
  end
end
