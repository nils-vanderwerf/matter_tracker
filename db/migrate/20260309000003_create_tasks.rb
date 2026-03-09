class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.date :due_date
      t.string :status, null: false, default: "Pending"
      t.string :priority, null: false, default: "Medium"
      t.references :matter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
