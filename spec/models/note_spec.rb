require "rails_helper"

RSpec.describe Note, type: :model do
  let(:matter) { create(:matter) }
  let(:note) { build(:note, matter: matter) }

  it "is valid with a body and matter" do
    expect(note).to be_valid
  end

  it "belongs to its matter" do
    expect(note.matter).to eq(matter)
  end
end
