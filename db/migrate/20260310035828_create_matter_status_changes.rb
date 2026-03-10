class CreateMatterStatusChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :matter_status_changes do |t|
      t.references :matter, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
