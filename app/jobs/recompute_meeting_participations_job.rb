# This class is only used to perform asynchronously the MeetingHelper@recompute_meeting_participations function
class RecomputeMeetingParticipationsJob < ApplicationJob
  queue_as :default

  # See the documentation for MeetingHelper@recompute_meeting_participations
  def perform(days_of_the_week, user)
    MeetingHelper.recompute_meeting_participations(days_of_the_week, user)
  end
end
