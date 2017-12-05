Rails.application.routes.draw do
  get 'user/new'

  resources :user
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'homepage#index', as: 'homepage'
  post '/' => 'homepage#post_index', as: 'root_post'
  post '/user/new', to: 'user#create'
  delete '/logout', to: 'homepage#destroy'

  # Calendar Page
  get 'calendar' => 'calendar#show'
end
