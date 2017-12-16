class DefaultLocationController < ApplicationController
	def show
		check_if_mine
		@default_location = DefaultLocation.find(params[:id])
	end

	private

	def check_if_mine(id = params[:id])
		unless current_user.default_locations.where(id: id).count() > 0
			raise ActionController::RoutingError, 'Not Found'
		end
	end
end
