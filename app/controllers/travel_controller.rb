class TravelController < ApplicationController
  def show
    @travel = Travel.find(params[:id])
    @travel_schedule = []
    @travel_schedule.push(get_starting_point)
    @travel_schedule = fill_with_travel_steps
    @travel_schedule.push(get_ending_point)
  end

  private

  def get_starting_point; end

  def get_ending_point; end
end
