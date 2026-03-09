class CreateMatters < ActiveRecord::Migration[7.0]
  def change
    create_table :matters do |t|
      t.string :title, null: false
      t.string :client, null: false
      t.string :matter_type, null: false
      t.string :status, null: false, default: "Open"
      t.date :due_date
      t.text :description

      t.timestamps
    end
  end
end
