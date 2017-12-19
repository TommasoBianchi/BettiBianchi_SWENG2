class RecomputeMeetingParticipationsJob < ApplicationJob
  queue_as :default

  def perform(days_of_the_week, user)
    MeetingHelper.recompute_meeting_participations(days_of_the_week, user)
  end
end
