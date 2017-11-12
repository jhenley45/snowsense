class CreateUserStations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_stations do |t|

      t.belongs_to :user, index: true
      t.belongs_to :station, index: true
      t.timestamps
    end
  end
end
