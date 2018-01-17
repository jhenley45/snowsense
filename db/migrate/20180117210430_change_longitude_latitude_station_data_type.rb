class ChangeLongitudeLatitudeStationDataType < ActiveRecord::Migration[5.0]
  def change
      change_column :stations, :longitude, :decimal, :precision=>10, :scale=>6
      change_column :stations, :latitude, :decimal, :precision=>10, :scale=>6
  end
end
