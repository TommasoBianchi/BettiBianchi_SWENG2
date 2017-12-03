Rails.application.routes.draw do
  get 'user/new'

  resources :user
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'homepage#index', as: 'root_get'
  post '/' => 'homepage#post_index', as: 'root_post'
  post '/complete_registration' => 'user#new'
  post '/login' => 'homepage#login', as: 'login'
  get '/complete_registration', to: 'homepage#complete_registration'
  post '/user/new', to: 'user#create'
  delete '/logout', to: 'homepage#destroy'
end
