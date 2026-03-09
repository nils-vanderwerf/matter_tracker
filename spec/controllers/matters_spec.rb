require "rails_helper"

RSpec.describe "Matters", type: :request do
  let(:client) { create(:client) }
  let(:matter) { create(:matter, client: client) }

  describe "GET /matters/:id" do
    it "returns 200" do
      get matter_path(matter)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /clients/:client_id/matters/new" do
    it "returns 200" do
      get new_client_matter_path(client)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /clients/:client_id/matters" do
    context "with valid params" do
      it "creates a matter and redirects" do
        expect {
          post client_matters_path(client), params: {
            matter: {
              title: "New Matter",
              matter_type: "Family Law",
              status: "Open",
              due_date: Date.today + 30
            }
          }
        }.to change(Matter, :count).by(1)

        expect(response).to redirect_to(matter_path(Matter.last))
      end
    end

    context "with invalid params" do
      it "does not create a matter and re-renders the form" do
        expect {
          post client_matters_path(client), params: {
            matter: { title: "", matter_type: "Family Law", status: "Open" }
          }
        }.not_to change(Matter, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /matters/:id/edit" do
    it "returns 200" do
      get edit_matter_path(matter)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /matters/:id" do
    context "with valid params" do
      it "updates the matter and redirects" do
        patch matter_path(matter), params: { matter: { title: "Updated Title" } }
        expect(response).to redirect_to(matter_path(matter))
        expect(matter.reload.title).to eq("Updated Title")
      end
    end

    context "with invalid params" do
      it "re-renders the form" do
        patch matter_path(matter), params: { matter: { title: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /matters/:id" do
    it "destroys the matter and redirects to the client" do
      matter # create it
      expect {
        delete matter_path(matter)
      }.to change(Matter, :count).by(-1)

      expect(response).to redirect_to(client_url(client))
    end
  end
end
