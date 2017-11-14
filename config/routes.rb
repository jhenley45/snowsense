Rails.application.routes.draw do

    devise_for :users
    root to: "stations#index"

    resources :stations do
      get 'timeseries'
    end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
