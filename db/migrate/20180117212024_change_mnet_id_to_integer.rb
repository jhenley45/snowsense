class ChangeMnetIdToInteger < ActiveRecord::Migration[5.0]
  def change
      change_column :stations, :mnet_id, :integer
  end
end
