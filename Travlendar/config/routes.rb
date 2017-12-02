Rails.application.routes.draw do
  get 'user/new'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/" => "homepage#index", :as => 'root'
  post "/" => "homepage#post_index"

  resources :user
  resources :homepage
end
