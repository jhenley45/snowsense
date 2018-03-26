class UserStationsController < ApplicationController

  def update
    station = current_user.user_stations.find_by_station_id(user_station_params["id"])
    station.update(nickname: user_station_params["nickname"])

    render json: station
  end

  private

  def user_station_params
    params.permit(:id, :nickname)
  end

end
