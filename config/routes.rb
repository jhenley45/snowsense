Rails.application.routes.draw do

    devise_for :users
    root to: "stations#index"

    resources :stations, except: :show do
      get 'timeseries'
    end

    get     'station_list', to: 'stations#station_list'
    get '/stations/search', to: 'stations#search'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
