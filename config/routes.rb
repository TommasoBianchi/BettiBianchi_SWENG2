Rails.application.routes.draw do
  get 'user/new'

  resources :user
  resources :meeting
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'homepage#index', as: 'homepage'
  post '/' => 'homepage#post_index', as: 'root_post'
  post '/user/new', to: 'user#create'
  delete '/logout', to: 'homepage#destroy'

  # Meeting
  get 'participants_page' => 'meeting#participants_page'

  # Calendar Page
  get 'calendar/day/:year/:month/:day' => 'calendar#show_day', constraints: { year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/ }
  get 'calendar/week/:year/:week' => 'calendar#show_week', constraints: { year: /\d{4}/, week: /\d{1,2}/ }
  get 'calendar/month/:year/:month' => 'calendar#show_month', constraints: { year: /\d{4}/, month: /\d{1,2}/ }
end
