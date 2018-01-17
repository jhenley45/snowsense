require 'httparty'
require 'pry'

namespace :stations do
  desc "Get all stations in MesoWest database and store them locally"

  task :get => :environment do

    url = "http://api.mesowest.net/v2/stations/metadata?&token=fa5fe15a26144b008df92a16b58b6539"

    mesowest_stations = HTTParty.get(url, format: :plain)
    mesowest_stations = JSON.parse(mesowest_stations)

    mesowest_stations["STATION"].each_with_index do |station, index|
      existing_station = Station.find_by_stid(station["STATION"])

      if !existing_station
        new_station = Station.create(
          name: station["NAME"],
          elevation: station["ELEVATION"],
          stid: station["STID"],
          longitude: station["LONGITUDE"].to_f,
          latitude: station["LATITUDE"].to_f,
          state: station["STATE"],
          mnet_id: station["MNET_ID"],
          is_active: station["STATUS"] === "ACTIVE" ? 1 : 0
        )
        puts("Created station with STID: " + new_station.stid + " --- " + index.to_s)
      end
    end

  end

end
