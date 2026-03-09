require "rails_helper"

RSpec.describe Client, type: :model do
  describe "validations" do
    it "is valid with a name" do
      client = build(:client, name: "Joe")
      expect(client).to be_valid
    end

    it "is invalid with a blank name" do
      client = build(:client, name: "")
      expect(client).not_to be_valid
    end

    it "is valid with a valid email" do
      client = build(:client, email: "correct_email@email.com")
      expect(client).to be_valid
    end

    it "is invalid with a bad email" do
      client = build(:client, email: "notanemail")
      expect(client).not_to be_valid
    end

    it "is valid with no email" do
      client = build(:client, email: nil)
      expect(client).to be_valid
    end
  end

  describe "scopes" do
    it "lists clients in alphabetical order by name" do
      bob = create(:client, name: "Bob")
      alice = create(:client, name: "Alice")
      nils = create(:client, name: "Nils")

      expect(Client.alphabetical.map(&:name)).to eq(["Alice", "Bob", "Nils"])
    end
  end
end
