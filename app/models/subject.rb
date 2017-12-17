class Subject < ApplicationRecord
	has_many :operators
	has_many :values

	validates :name, presence: true
	validate :name_correctness

	def get_path_value(path)
		return path[Subjects[name]]
	end

	private
	Subjects = {
		"Distance" => :distance,
		"Duration" => :duration,
		"Start time" => :start_time,
		"End time" => :end_time
	}

	def name_correctness
	  	if name.blank?
	  		return
	  	end
	  	unless Subjects.keys.include? name
	  		errors.add(:name, "must be between one of #{Subjects.keys}")
	    end
  	end
end
