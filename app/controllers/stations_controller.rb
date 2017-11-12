class StationsController < ApplicationController


  def index
    @new_station = Station.new
  end

  def create
    station_id = station_params[:stid]
    url = "http://api.mesowest.net/v2/stations/metadata?&token=#{ENV['MESO_API_TOKEN']}&stids=#{station_id}"
    response = HTTParty.get(url, format: :plain)
    json = JSON.parse(response)
    station = json['STATION'] ? json['STATION'].first : nil;

    if !station
      flash[:error] = "No station found with that station ID. Please try again."
    else

      existing_station = Station.find_by_stid(station["STID"])

      if existing_station
        current_user.stations.create(existing_station)
      else
        new_station = Station.create(
          name: station["NAME"],
          elevation: station["ELEVATION"],
          stid: station["STID"],
          longitude: station["LONGITUDE"],
          latitude: station["LATITUDE"],
          state: station["STATE"]
        )

        current_user.stations << new_station
      end
    end

    redirect_to action: 'index'
  end

  private

  def station_params
    params.require(:station).permit(:stid)
  end
end
