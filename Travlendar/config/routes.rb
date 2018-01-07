Rails.application.routes.draw do

	resources :user
	resources :meeting
	resources :notification, only: [:index]
	resources :default_location


	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	get '/' => 'homepage#index', as: 'homepage'
	post '/' => 'homepage#post_index', as: 'root_post'
	post '/user/new', to: 'user#create'
	delete '/logout', to: 'homepage#destroy'

	# User
	get 'user/new'
	post 'user/:id/edit', to: 'user#post_edit'
	get 'user/search/:id' => 'user#search', as: 'search_user'
	get 'user/search_contacts/:id' => 'user#search_contacts', as: 'search_user_contact'
	get 'user/contacts/:id' => 'user#contacts', as: 'contacts_page'
	get 'user/remove_from_contacts/:user_id/:to_delete_id' => 'user#delete_contact', as: 'delete_contact'
	get 'user/add_to_contacts/:user_id/:to_add_id' => 'user#add_contact', as: 'add_contact'
	get 'user/:id/settings' => 'user#settings', as: 'settings_page'
	patch 'user/:id/settings/change_preference_list' => 'user#change_preference_list', as: 'change_preference_list'
	get 'user/:id/add_constraint' => 'user#add_constraint', as: 'add_constraint'
	post 'user/:id/add_constraint', to: 'user#create_constraint'
	get 'user/delete_constraint/:user_id/:constraint_id' => 'user#delate_constraint', as: 'delete_constraint'
	get 'user/delete_email/:user_id/:email_id' => 'user#delete_email', as: 'delete_email'
	get 'user/delete_social/:user_id/:social_user_id' => 'user#delete_social', as: 'delete_social'

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

	# Notification
	get 'notification/resolve_warning/:meeting_participation_id' => 'notification#resolve_warning', as: 'resolve_warning'

	# Default Location
	post 'default_location/new', to: 'default_location#create'
	get 'default_location/delete_dl/:default_location_id/:user_id' => 'default_location#delete', as: 'delete_default_location'
	get 'default_location/first_def_location/:user_id' => 'default_location#first_def_location', as: 'create_first_def_location'
	post 'default_location/first_def_location/:user_id', to: 'default_location#first_creation'

	# Break
	get 'break/:id/add_break' => 'break#add_break', as: 'add_break'
	post 'break/:id/add_break', to: 'break#create_break'
	get 'user/delete_break/:user_id/:break_id' => 'break#delete_break', as: 'delete_break'
end
