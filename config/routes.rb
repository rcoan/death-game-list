Rails.application.routes.draw do
  devise_for :users, skip: [:registrations], controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "dashboard#home"
  get "dashboard/year/:year", to: "dashboard#index", as: :year_dashboard
  get "regras", to: "dashboard#rules", as: :rules

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :player_lists, only: [:index, :show, :create, :destroy]
  get "autocomplete/celebrities", to: "autocomplete#celebrities"

  resources :celebrities, only: [:index, :show, :new, :create, :edit, :update] do
    collection do
      get :find_duplicates
      post :bulk_merge
    end
    member do
      get :mark_deceased
      patch :update_deceased, as: :update_deceased
      post :merge
    end
  end

  namespace :admin do
    resources :users do
      member do
        get :manage_list
        post :add_celebrity_to_list
        delete :remove_from_list
      end
    end
    resources :game_years
    resources :imports, only: [:index, :new, :create]
  end
end
