require "rails_helper"

RSpec.describe "Notes", type: :request do
  let(:matter) { create(:matter) }
  let(:note)   { create(:note, matter: matter) }

  describe "POST /matters/:matter_id/notes" do
    context "with valid params" do
      it "creates a note and redirects to the matter" do
        expect {
          post matter_notes_path(matter), params: { note: { body: "Important update." } }
        }.to change(Note, :count).by(1)

        expect(response).to redirect_to(matter_path(matter))
      end
    end

    context "with blank body" do
      it "does not create a note and redirects back with alert" do
        expect {
          post matter_notes_path(matter), params: { note: { body: "" } }
        }.not_to change(Note, :count)

        expect(response).to redirect_to(matter_path(matter))
      end
    end
  end

  describe "GET /notes/:id/edit" do
    it "returns 200" do
      get edit_note_path(note)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /notes/:id" do
    context "with valid params" do
      it "updates the note and redirects to the matter" do
        patch note_path(note), params: { note: { body: "Revised note." } }
        expect(response).to redirect_to(matter_path(matter))
        expect(note.reload.body).to eq("Revised note.")
      end
    end

    context "with blank body" do
      it "re-renders the edit form" do
        patch note_path(note), params: { note: { body: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /notes/:id" do
    it "destroys the note and redirects to the matter" do
      note # create it
      expect {
        delete note_path(note)
      }.to change(Note, :count).by(-1)

      expect(response).to redirect_to(matter_path(matter))
    end
  end
end
