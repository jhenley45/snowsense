class CreateStations < ActiveRecord::Migration[5.0]
  def change
    create_table :stations do |t|
      t.string :name
      t.integer :elevation
      t.string :stid
      t.string :longitude
      t.string :latitude
      t.string :state

      t.timestamps
    end
  end
end
