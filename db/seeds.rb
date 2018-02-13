# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

######################################################################################################

# Profile the seeder
_seed_start_time_ = DateTime.now

# DUMP EVERYTHING BEFORE RE-SEEDING
ActiveRecord::Base.establish_connection
ActiveRecord::Base.connection.tables.each do |table|
	next if table == 'schema_migrations'

	# MySQL and PostgreSQL
	ActiveRecord::Base.connection.execute("TRUNCATE #{table} RESTART IDENTITY CASCADE")

	# SQLite
	# ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
end
# DUMP EVERYTHING BEFORE RE-SEEDING

def create_travel_steps(travel)
	travel_duration = travel.get_duration_integer_minutes
	starting_travel_mean_datetime = travel.start_time - (travel_duration / NUM_TRAVEL_STEPS).minutes
	ending_travel_mean_datetime = travel.start_time
	for j in 1..NUM_TRAVEL_STEPS do
		starting_travel_mean_datetime += (travel_duration / NUM_TRAVEL_STEPS).minutes
		ending_travel_mean_datetime += (travel_duration / NUM_TRAVEL_STEPS).minutes
		travel_mean = rand(0..NUM_TRAVEL_MEANS)
		distance = rand * MAX_DISTANCE
		TravelStep.create(start_time: starting_travel_mean_datetime, end_time: ending_travel_mean_datetime, travel_mean: travel_mean, distance: distance, travel_id: travel.id)

		i = travel.id
		puts "Travel #{i} - TravelStep #{j}"
	end
end

NUM_GROUPS = 3
NUM_SOCIALS = Social::Social_type.count
NUM_EMAILS_PER_USER = 2
# NUM_STATUSES_PER_USER = 2
NUM_CONTACTS_PER_USER = 1
NUM_BREAKS_PER_USER = 4
NUM_USERS = 3
NUM_MEETINGS_DAYS = 10
NUM_MEETINGS_PER_DAY = 3
NUM_MEETINGS = NUM_MEETINGS_DAYS * NUM_MEETINGS_PER_DAY
NUM_CATEGORIES = 10
NUM_TRAVELS = 5
NUM_VALUES = 10
NUM_CONSTRAINTS = 15
NUM_TRAVEL_MEANS = 3
MAX_DISTANCE = 20
NUM_RESPONSE_STATUSES = 3
NUM_DEFAULT_LOCATIONS_PER_USER = 3
NUM_TRAVEL_STEPS = 3
NUM_VALUES_PER_SUBJECT = 3

locations = []
locations.push Location.create({latitude: 45.4830988, longitude: 9.2165046, description: "Via Niccolò Paganini, 17, 20131 Milano Mi, Italia"})
locations.push Location.create({latitude: 45.4891041, longitude: 9.2119859, description: "Via Mauro Macchi, 89, 20127 Milano MI, Italia"})
locations.push Location.create({latitude: 45.478085, longitude: 9.225690799999938, description: "Piazza Leonardo Milano"})
locations.push Location.create({latitude: 45.477151, longitude: 9.230428699999948, description: "Via Ponzio 24 Milano"})
locations.push Location.create({latitude: 45.4775608, longitude: 9.234494199999972, description: "Via Golgi 40 Milano"})
locations.push Location.create({latitude: 45.4637307, longitude: 9.191084100000012, description: "Piazza Duomo Milano"})
locations.push Location.create({latitude: 45.4832711, longitude: 9.190058499999964, description: "Piazza Gae Aulenti Milano"})
locations.push Location.create({latitude: 45.4531899, longitude: 9.1699315, description: "Porta Genova Milano"})
locations.push Location.create({latitude: 45.4781236, longitude: 9.123962, description: "Piazzale Angelo Moratti, 20151 Milano MI, Italia"})
locations.push Location.create({latitude: 45.476008, longitude: 9.1683606, description: "Via Antonio Canova, 20145 Milano MI, Italia"})
NUM_LOCATIONS = locations.length

for i in 1..NUM_GROUPS do
	Group.create(name: 'Group' + i.to_s)
	puts "Group #{i}"
end

Social::Social_type.each do |social|
	Social.create(name: social[1][:name], icon_path: social[1][:icon_path])
	puts "Social #{i}"
end


NUM_OPERATORS = Operator::Operators.length
Subject::Subjects.keys.each do |name|
	subject = Subject.create(name: name)

	puts "Subject: #{name}"

	for i in 0..NUM_OPERATORS - 1 do
		operator = Operator.create(description: Operator::Operators[i].name.to_s, subject_id: subject.id, operator: i)

		puts "Operator #{i}"
	end

	for j in 1..NUM_VALUES_PER_SUBJECT do
		Value.create(value: (1500 * j).to_s, subject_id: subject.id)
	end
end
NUM_SUBJECTS = Subject::Subjects.keys.length

for i in 1..NUM_USERS do
	user = User.create(name: 'User' + i.to_s, surname: 'Surname' + i.to_s, password: '0000', password_confirmation: '0000', nickname: 'U' + i.to_s, preference_list: '021', website: 'http://www.google.com', company: 'BettiBianchi s.r.l.')
	IncompleteUser.create(email: 'User' + i.to_s + '.Surname@travlendar.com', password: '0000', password_confirmation: '0000')
	user.groups.push(Group.find(i % NUM_GROUPS + 1))
	k = Social::Social_type.keys.sample
	SocialUser.create(social_id: k, link: 'www.#{Social::Social_type[k][:name]}.com', user_id: user.id)
	k = Social::Social_type.keys.sample
	SocialUser.create(social_id: k, link: 'www.#{Social::Social_type[k][:name]}.com', user_id: user.id)

	for j in 1..NUM_EMAILS_PER_USER do
		email = Email.create(email: 'User' + i.to_s + '.Surname.' + j.to_s + '@travlendar.com', user_id: user.id)
		user.emails.push(email)
	end

	for j in 1..NUM_BREAKS_PER_USER do
		start_time_slot = rand(400..1000) # represented in minutes after midnight
		end_time_slot = start_time_slot + rand(60..180)
		default_time = (start_time_slot + end_time_slot) / 2
		duration = (end_time_slot - start_time_slot) / 10
		b = Break.create(default_time: default_time, start_time_slot: start_time_slot, end_time_slot: end_time_slot,
										 duration: duration, name: 'Break' + j.to_s, day_of_the_week: j % 7, user_id: i)
	end

	number_of_default_locations = 0
	for j in 1..NUM_DEFAULT_LOCATIONS_PER_USER do
		starting_hour = (j * 450) % (24 * 60) # represented in minutes after midnight
		for k in 0..6 do
			DefaultLocation.create(starting_hour: starting_hour, day_of_the_week: k,
														 name: 'Default Location ' + number_of_default_locations.to_s, user_id: i, location_id: rand(1..NUM_LOCATIONS))
			number_of_default_locations += 1
		end
	end

	primary_email = Email.create(email: 'User' + i.to_s + '.Surname@travlendar.com', user_id: i)
	user.primary_email_id = primary_email.id

	unless user.save
		user.errors.full_messages.each do |message|
			puts(message)
		end
	end

	#######
	distance_subject = Subject.find_by(name: "Distance")
	distance_greater_op = Operator.where(subject: distance_subject, operator: 3).first
	distance_lesser_op = Operator.where(subject: distance_subject, operator: 2).first
	duration_subject = Subject.find_by(name: "Duration")
	duration_greater_op = Operator.where(subject: duration_subject, operator: 3).first
	# Do not walk if distance is greater than 5 km
	Constraint.create({travel_mean: 0, subject: distance_subject, operator: distance_greater_op,
										 value: Value.where(subject: distance_subject).sample, user: user})
	# Do not walk if duration is greater than 30 min
	Constraint.create({travel_mean: 0, subject: duration_subject, operator: duration_greater_op,
										 value: Value.where(subject: duration_subject).sample, user: user})
	# Do not use public transportation if duration is greater than 2 h
	Constraint.create({travel_mean: 2, subject: duration_subject, operator: duration_greater_op,
										 value: Value.where(subject: duration_subject).sample, user: user})
	# Do not use driving if distance is lesser than 2 km
	Constraint.create({travel_mean: 1, subject: distance_subject, operator: distance_lesser_op,
										 value: Value.where(subject: distance_subject).sample, user: user})
	#######

	puts "User #{i}"
end

for i in 1..NUM_USERS do
	user = User.find(i)
	for k in 1..NUM_CONTACTS_PER_USER do
		j = rand(1..NUM_USERS)
		j = rand(1..NUM_USERS) while (j == i or user.contacts.ids.include?(j))
		user.contacts.push(User.find(j))

		puts "Contact #{i} -> #{j}"
	end
end

meeting_number = 1
for i in (-NUM_MEETINGS_DAYS / 2)..(NUM_MEETINGS_DAYS / 2) do
	day = DateTime.now + i.days
	for k in 1..NUM_MEETINGS_PER_DAY do
		start_date = DateTime.new(day.year, day.month, day.day, rand(8..20), rand(0..59), 0)
		end_date = start_date + rand(30..120).minutes
		title = 'NewMeeting ' + meeting_number.to_s
		abstract = "meeting from a seed"
		result = MeetingHelper.create_meeting start_date, end_date, title, abstract, Location.find(rand(1..NUM_LOCATIONS)), User.find(1)
		meeting_number += 1

		if result[:status] == :errors
			return
		end

		puts "Meeting #{result[:meeting].id} - Created"

		for j in 2..NUM_USERS do
			res = MeetingHelper.invite_to_meeting result[:meeting], User.find(j)

			if res[:status] == :errors
				return
			end

			puts "Meeting #{result[:meeting].id} - Invited user #{j}"
		end

	end
end

for i in 1..NUM_CATEGORIES do
	cat = Category.create(name: 'category' + i.to_s, superclass_id: 1)

	puts "Category #{i}"
end

for i in 1..NUM_CATEGORIES do
	j = rand(1..NUM_CATEGORIES)
	j = rand(1..NUM_CATEGORIES) while j == i
	Category.find(i).superclass_id = Category.find(j).id
end

# Profile the seeder
_seed_end_time_ = DateTime.now

puts "\nSeeder run in #{_seed_end_time_.to_i - _seed_start_time_.to_i} seconds\n"