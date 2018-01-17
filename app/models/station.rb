class Station < ApplicationRecord
    has_many :user_stations
    has_many :users, through: :user_stations

    reverse_geocoded_by :latitude, :longitude

end
