class MeetingParticipationConflict < ApplicationRecord
	belongs_to :meeting_participation1, class_name: 'MeetingParticipation', foreign_key: 'meeting_participation_1_id'
	belongs_to :meeting_participation2, class_name: 'MeetingParticipation', foreign_key: 'meeting_participation_2_id'
end
