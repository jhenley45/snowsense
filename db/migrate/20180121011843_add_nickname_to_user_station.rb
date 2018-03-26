class AddNicknameToUserStation < ActiveRecord::Migration[5.0]
  def change
    add_column :user_stations, :nickname, :string
  end
end
