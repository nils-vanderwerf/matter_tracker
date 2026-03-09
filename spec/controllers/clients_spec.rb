require "rails_helper"

RSpec.describe "Clients", type: :request do
  describe "GET /clients" do
    it "returns 200" do
      get clients_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /clients/:id" do
    it "returns 200" do
      client = create(:client)
      get client_path(client)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /clients/new" do
    it "returns 200" do
      get new_client_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /clients" do
    context "with valid params" do
      it "creates a client and redirects" do
        expect {
          post clients_path, params: { client: { name: "Jane Smith", email: "jane@example.com" } }
        }.to change(Client, :count).by(1)

        expect(response).to redirect_to(client_path(Client.last))
      end
    end

    context "with invalid params" do
      it "does not create a client and re-renders the form" do
        expect {
          post clients_path, params: { client: { name: "" } }
        }.not_to change(Client, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /clients/:id/edit" do
    it "returns 200" do
      client = create(:client)
      get edit_client_path(client)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /clients/:id" do
    context "with valid params" do
      it "updates the client and redirects" do
        client = create(:client)
        patch client_path(client), params: { client: { name: "Updated Name" } }
        expect(response).to redirect_to(client_path(client))
        expect(client.reload.name).to eq("Updated Name")
      end
    end

    context "with invalid params" do
      it "re-renders the form" do
        client = create(:client)
        patch client_path(client), params: { client: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /clients/:id" do
    it "destroys the client and redirects to index" do
      client = create(:client)
      expect {
        delete client_path(client)
      }.to change(Client, :count).by(-1)

      expect(response).to redirect_to(clients_url)
    end
  end
end
