class MakeMattersClientStringNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :matters, :client, true
  end
end
