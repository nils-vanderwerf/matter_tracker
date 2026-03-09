class AddClientReferenceToMatters < ActiveRecord::Migration[7.0]
  def change
    add_reference :matters, :client, foreign_key: true
  end
end
