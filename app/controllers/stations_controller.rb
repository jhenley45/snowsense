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
        if current_user.stations.find_by_stid(existing_station.stid)
          flash[:warning] = "Station already exists."
        else
          current_user.stations << existing_station
          flash[:success] = "Station has been added to your profile."
        end
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
        flash[:success] = "Station has been added to your profile."
      end


    end

    redirect_to action: 'index'
  end

  private

  def station_params
    params.require(:station).permit(:stid)
  end
end
