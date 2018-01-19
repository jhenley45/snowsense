class StationsController < ApplicationController

  CLIMATOLOGY_URL = "http://api.mesowest.net/v2/stations/climatology?&startclim=07010000&endclim=07020000&units=ENGLISH&obtimezone=local&token=#{ENV['MESO_API_TOKEN']}"
  STATISTICS_URL = "http://api.mesowest.net/v2/stations/statistics?&type=all&units=ENGLISH&obtimezone=local&token=#{ENV['MESO_API_TOKEN']}"
  LATEST_URL = "http://api.mesowest.net/v2/stations/latest?&units=ENGLISH&within=14400&obtimezone=local&token=#{ENV['MESO_API_TOKEN']}"
  # no good, doesn't give snow data
  # PRECIP_URL = "http://api.mesowest.net/v2/stations/precipitation?&units=ENGLISH&start=201711011800&end=201711111800&obtimezone=local&token=#{ENV['MESO_API_TOKEN']}"
  TIMESERIES_URL = "http://api.mesowest.net/v2/stations/timeseries?&units=ENGLISH&obtimezone=local&showemptystations=1&token=#{ENV['MESO_API_TOKEN']}"
  NEAREST_URL = "http://api.mesowest.net/v2/stations/nearesttime?&atttime=201711121200&units=ENGLISH&obtimezone=local&showemptystations=1&token=#{ENV['MESO_API_TOKEN']}"

  def index
    @new_station = Station.new

    @station_data = []

    @stations = current_user.stations
    station_ids = @stations.collect(&:stid)
    stations_string = station_ids.join(",")

    now = DateTime.now.utc

    start_time = now.strftime("%Y%m%d%H%M")
    back_24 = (now - 24.hours).strftime("%Y%m%d%H%M")
    back_48 = (now - 48.hours).strftime("%Y%m%d%H%M")
    back_72 = (now - 72.hours).strftime("%Y%m%d%H%M")

    stats_url = STATISTICS_URL + "&stids=#{stations_string}"
    stats_24 = stats_url + "&end=#{start_time}&start=#{back_24}"
    stats_48 = stats_url + "&end=#{start_time}&start=#{back_48}"
    stats_72 = stats_url + "&end=#{start_time}&start=#{back_72}"

    stats_24_json = JSON.parse(HTTParty.get(stats_24, format: :plain))
    stats_48_json = JSON.parse(HTTParty.get(stats_48, format: :plain))
    stats_72_json = JSON.parse(HTTParty.get(stats_72, format: :plain))

    @stations.each do |station|
      data_24 = stats_24_json["STATION"].find { |hash| hash["STID"].upcase == station.stid.upcase}
      data_48 = stats_48_json["STATION"].find { |hash| hash["STID"].upcase == station.stid.upcase}
      data_72 = stats_72_json["STATION"].find { |hash| hash["STID"].upcase == station.stid.upcase}

      object = {}
      object[:id] = station.id
      object[:name] = station.name
      object[:stid] = station.stid
      object[:tables] = []

      temp_table = { title: "Temperature", short_title: "Temp", rows: [] }

      temp_min = { spec: "Min", hourly: {} }
      temp_min[:hourly][:twenty_four]   = dig_deep(data_24["STATISTICS"], ["air_temp_set_1", "minimum"])
      temp_min[:hourly][:fourty_eight]  = dig_deep(data_48["STATISTICS"], ["air_temp_set_1", "minimum"])
      temp_min[:hourly][:seventy_two]   = dig_deep(data_72["STATISTICS"], ["air_temp_set_1", "minimum"])
      temp_table[:rows].push(temp_min)

      temp_avg = { spec: "Avg", hourly: {} }
      temp_avg[:hourly][:twenty_four]   = dig_deep(data_24["STATISTICS"], ["air_temp_set_1", "average"])
      temp_avg[:hourly][:fourty_eight]  = dig_deep(data_48["STATISTICS"], ["air_temp_set_1", "average"])
      temp_avg[:hourly][:seventy_two]   = dig_deep(data_72["STATISTICS"], ["air_temp_set_1", "average"])
      temp_table[:rows].push(temp_avg)

      temp_max = { spec: "Max", hourly: {} }
      temp_max[:hourly][:twenty_four]   = dig_deep(data_24["STATISTICS"], ["air_temp_set_1", "maximum"])
      temp_max[:hourly][:fourty_eight]  = dig_deep(data_48["STATISTICS"], ["air_temp_set_1", "maximum"])
      temp_max[:hourly][:seventy_two]   = dig_deep(data_72["STATISTICS"], ["air_temp_set_1", "maximum"])
      temp_table[:rows].push(temp_max)

      object[:tables].push(temp_table)


      wind_table = { title: "Wind Speed", short_title: "Speed", rows: [] }

      wind_min = { spec: "Min", hourly: {} }
      wind_min[:hourly][:twenty_four]   = dig_deep(data_24["STATISTICS"], ["wind_speed_set_1", "minimum"])
      wind_min[:hourly][:fourty_eight]  = dig_deep(data_48["STATISTICS"], ["wind_speed_set_1", "minimum"])
      wind_min[:hourly][:seventy_two]   = dig_deep(data_72["STATISTICS"], ["wind_speed_set_1", "minimum"])
      wind_table[:rows].push(wind_min)

      wind_avg = { spec: "Avg", hourly: {} }
      wind_avg[:hourly][:twenty_four]   = dig_deep(data_24["STATISTICS"], ["wind_speed_set_1", "average"])
      wind_avg[:hourly][:fourty_eight]  = dig_deep(data_48["STATISTICS"], ["wind_speed_set_1", "average"])
      wind_avg[:hourly][:seventy_two]   = dig_deep(data_72["STATISTICS"], ["wind_speed_set_1", "average"])
      wind_table[:rows].push(wind_avg)

      wind_max = { spec: "Max", hourly: {} }
      wind_max[:hourly][:twenty_four]   = dig_deep(data_24["STATISTICS"], ["wind_speed_set_1", "maximum"])
      wind_max[:hourly][:fourty_eight]  = dig_deep(data_48["STATISTICS"], ["wind_speed_set_1", "maximum"])
      wind_max[:hourly][:seventy_two]   = dig_deep(data_72["STATISTICS"], ["wind_speed_set_1", "maximum"])
      wind_table[:rows].push(wind_max)

      object[:tables].push(wind_table)

      @station_data.push(object)
    end

    # For current snow depth and air temp. Take last value in array
    # "OBSERVATIONS"=>
    # {"date_time"=>["2017-11-12T14:00:00-0700"],
    #  "volt_set_1"=>[13.8],
    #  "snow_interval_set_1"=>[4.0],
    #  "dew_point_temperature_set_1d"=>[16.54],
    #  "precip_accum_fifteen_minute_set_1"=>[0.0],
    #  "snow_depth_set_1"=>[33.0],
    #  "relative_humidity_set_1"=>[55.0],
    #  "air_temp_set_1"=>[30.99]},
    # current = TIMESERIES_URL + "&stids=#{stations_string}"
    # current_response = HTTParty.get(current, format: :plain)
    # current_json = JSON.parse(current_response)


    # For recent snowfall over a period of time from present. Is this 24 hours??
    # "OBSERVATIONS"=>
    #   "snow_interval_value_1"=>
    #    {"date_time"=>"2017-11-12T14:15:00-0700", "value"=>4.0},
    # latest = LATEST_URL + "&stids=#{stations_string}"
    # latest_response = HTTParty.get(latest, format: :plain)
    # latest_json = JSON.parse(latest_response)


    # {"volt_set_1"=>{"date_time"=>"2017-11-11T11:00:00-0700", "maximum"=>14.8},
    #   "snow_interval_set_1"=>
    #    {"date_time"=>"2017-11-01T22:30:00-0600", "maximum"=>45.0},
    #   "precip_accum_fifteen_minute_set_1"=>
    #    {"date_time"=>"2017-11-06T18:00:00-0700", "maximum"=>0.06},
    #   "snow_depth_set_1"=>
    #    {"date_time"=>"2017-11-06T14:15:00-0700", "maximum"=>167.0},
    #   "relative_humidity_set_1"=>
    #    {"date_time"=>"2017-11-03T20:45:00-0600", "maximum"=>99.0},
    #   "air_temp_set_1"=>
    #    {"date_time"=>"2017-11-01T15:15:00-0600", "maximum"=>37.99}},
    # stats = STATISTICS_URL + "&stids=#{stations_string}"
    # stats_response = HTTParty.get(stats, format: :plain)
    # stats_json = JSON.parse(stats_response)


    # stats = NEAREST_URL + "&stids=#{stations_string}"
    # stats_response = HTTParty.get(stats, format: :plain)
    # stats_json = JSON.parse(stats_response)
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

    station = existing_station ? existing_station : new_station

    render :json => station
    # redirect_to action: 'index'
  end

  def destroy
    station_id = params[:id]
    station = Station.find(station_id)
    current_user.stations.delete(station)

    flash[:success] = "Station has been removed from your profile."

    redirect_to action: 'index'
  end


  def timeseries

    station_id = timeseries_params[:station_id]
    station = Station.find(station_id)
    timeseries_url = TIMESERIES_URL + "&stids=#{station.stid}"

    now = DateTime.now.utc
    end_time = now.strftime("%Y%m%d%H%M")
    days_back = timeseries_params[:days_back]
    start_time = (now - days_back.to_i.days).strftime("%Y%m%d%H%M")
    timeseries_url = timeseries_url + "&end=#{end_time}&start=#{start_time}"

    timeseries_json = JSON.parse(HTTParty.get(timeseries_url, format: :plain))

    data = []

    timeseries_json["STATION"][0]["OBSERVATIONS"]["date_time"].each_with_index do |date, index|
      obj = {}
      obj[:date_time] = date
      obj[:temperature] = dig_deep(timeseries_json["STATION"][0]["OBSERVATIONS"], ["air_temp_set_1", index])
      obj[:wind_speed] = dig_deep(timeseries_json["STATION"][0]["OBSERVATIONS"], ["wind_speed_set_1", index])
      obj[:wind_gusts] = dig_deep(timeseries_json["STATION"][0]["OBSERVATIONS"], ["wind_gust_set_1", index])
      obj[:wind_directions] = dig_deep(timeseries_json["STATION"][0]["OBSERVATIONS"], ["wind_cardinal_direction_set_1d", index])
      data.push(obj)
    end

    render json: data
  end

  def station_list
    @stations = current_user.stations

    station_data = @stations.map do |station|
      obj = {}
      obj[:id] = station.id
      obj[:station] = station.name
      obj[:stid] = station.stid
      obj
    end

    render json: station_data
  end

  def search
    results = Station.where("name LIKE ?", "%#{search_params[:query]}%")

    render json: results
  end

  def active_stations

    active_stations = Station.near("Jackson, Wyoming").where(is_active: 1)

    geo_json = []

    active_stations.each do |station|
      geo_json << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [station.longitude, station.latitude]
        },
        properties: {
          name: station.name,
          elevation: station.elevation,
          id: station.id,
          stid: station.stid
        }
      }
    end

    render json: geo_json
  end


  private

  def station_params
    params.require(:station).permit(:stid)
  end

  def timeseries_params
    params.permit(:station_id, :days_back)
  end

  def search_params
    params.permit(:query)
  end

  def dig_deep(hash, keys)
    current_place = hash

    value = keys.each_with_index do |key, index|
      break nil if !current_place
      break current_place[key] if index == keys.length - 1

      current_place = current_place[key]
    end

    return value
  end
end
