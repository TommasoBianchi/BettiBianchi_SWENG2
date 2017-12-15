Rails.application.routes.draw do

	resources :user
	resources :meeting
	resources :notification, only: [:index]

	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	get '/' => 'homepage#index', as: 'homepage'
	post '/' => 'homepage#post_index', as: 'root_post'
	post '/user/new', to: 'user#create'
	delete '/logout', to: 'homepage#destroy'

	# User
	get 'user/new'
	get 'user/search' => 'user#search', as: 'user_search'

	# Meeting
	get 'meeting/:id/participants_page' => 'meeting#participants_page', as: 'participants_page'
	get 'meeting/remove_participant/:meeting_id/:user_id' => 'meeting#remove_from_meeting', as: 'remove_from_meeting'
	get 'meeting/nominate_admin/:meeting_id/:user_id' => 'meeting#nominate_admin', as: 'nominate_admin'
	post '/meeting/new', to: 'meeting#create'
	get 'meeting/accept_participation/:meeting_id/:user_id' => 'meeting#accept', as: 'accept_meeting'
	get 'meeting/decline_participation/:meeting_id/:user_id' => 'meeting#decline', as: 'decline_meeting'

	# Calendar Page
	get 'calendar/day/:year/:month/:day' => 'calendar#show_day', constraints: {year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/}, as: 'calendar_day', defaults: {year: DateTime.now.year, month: DateTime.now.month, day: DateTime.now.day}
	get 'calendar/week/:year/:week' => 'calendar#show_week', constraints: {year: /\d{4}/, week: /\d{1,2}/}, as: 'calendar_week'
	get 'calendar/month/:year/:month' => 'calendar#show_month', constraints: {year: /\d{4}/, month: /\d{1,2}/}, as: 'calendar_month'

	# Travel
	get 'travel/:id' => 'travel#show', as: 'show_travel'
end
