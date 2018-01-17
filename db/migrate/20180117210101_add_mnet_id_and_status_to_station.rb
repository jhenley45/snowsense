class AddMnetIdAndStatusToStation < ActiveRecord::Migration[5.0]
  def change
      add_column :stations, :mnet_id, :string
      add_column :stations, :is_active, :boolean
  end
end
