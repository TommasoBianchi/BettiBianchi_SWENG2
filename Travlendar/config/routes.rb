Rails.application.routes.draw do
  get 'user/new'

  resources :user
  resources :homepage
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'homepage#index', :as => 'root'
  post '/' => 'homepage#post_index'
  post '/complete_registration' => 'homepage#complete_registration', as: 'complete_registration'
  post '/login' => 'homepage#login', as: 'login'
  get '/complete_registration', to: 'homepage#complete_registration'
end
