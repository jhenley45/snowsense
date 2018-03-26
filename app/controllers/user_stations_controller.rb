class UserStationsController < ApplicationController

  def update
    puts user_station_params
  end

  private

  def user_station_params
    params.permit(:id, :nickname)
  end

end
