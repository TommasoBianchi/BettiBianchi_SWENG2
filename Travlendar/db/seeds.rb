# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

######################################################################################################

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

NUM_GROUPS = 3
NUM_SOCIALS = 4
NUM_EMAILS_PER_USER = 2
#NUM_BREAKS_PER_USER = 2
#NUM_STATUSES_PER_USER = 2
NUM_CONTACTS_PER_USER = 3
NUM_BREAKS_PER_USER = 1
NUM_USERS = 10
NUM_MEETINGS = 4
NUM_CATEGORIES = 10

for i in 1..NUM_GROUPS do
	Group.create({name: 'Group' + i.to_s})
end

for i in 1..NUM_SOCIALS do
	Social.create({name: 'Social' + i.to_s})
end

for i in 1..NUM_USERS do
	user = User.create({name: 'Pinco' + i.to_s, surname: 'Pallo' + i.to_s, password: '0000', nickname: 'PP' + i.to_s})
	user.groups.push(Group.find(i % NUM_GROUPS + 1))
	user.socials.push(Social.find(i % NUM_SOCIALS + 1))

	for j in 1..NUM_EMAILS_PER_USER do
		email = Email.create({email: 'Pinco' + i.to_s + '.Pallo.' + j.to_s + '@travlendar.com', user_id: user.id})
		user.emails.push(email)
	end

	for j in 1..NUM_BREAKS_PER_USER do
		start_time_slot = (j * 100) % (24 * 60)	# represented in minutes after midnight
		end_time_slot = (j * 200) % (24 * 60)	# represented in minutes after midnight
		default_time = (start_time_slot + end_time_slot) / 2
		duration = (end_time_slot - start_time_slot) / 10
		b = Break.create({default_time: default_time, start_time_slot: start_time_slot, end_time_slot: end_time_slot,
			duration: duration, name: 'Break' + j.to_s, day_of_the_week: j % 7, user_id: i})
	end

	user.primary_email = Email.create({email: 'Pinco' + i.to_s + '.Pallo@travlendar.com', user_id: user.id})
end

location = Location.create({latitude: 37.4133028, longitude: -122.1513074, description: "Mountain View"})

for i in 1..NUM_MEETINGS do
  new_start_date = DateTime.new(2017, i % 12, i % 28, 12, 35, 0)
  end_date = DateTime.new(2017, i % 12, i % 28, 14, 35, 0)
	meeting = Meeting.create({location_id: location.id, title: 'NewMeeting' + i.to_s, start_date: new_start_date, end_date: end_date})
end

for i in 1..NUM_USERS do
	user = User.find(i)
	for k in 1..NUM_CONTACTS_PER_USER do
		j = rand(1..NUM_USERS)
		while j == k do
			j = rand(1..NUM_USERS)
		end
		user.contacts.push(User.find(j))
	end

  for i in 1..NUM_CATEGORIES do
    cat = Category.create({name: 'category' + i.to_s, superclass_id: 1})
  end

#  for i in 1..NUM_CATEGORIES do
#    j = rand(1..NUM_CATEGORIES)
#    while j == i do
#			j = rand(1..NUM_CATEGORIES)
#		end
#    Category.find(i).superclass_id = Category.find(j).id
#  end

  subject = Subject.create({name: "firstSubject"})
  operator = Operator.create({description: "firstOperator", subject_id: subject.id})
  value = Value.create({value: "firstValue", subject_id: subject.id})
  constraint = Constraint.create({travel_mean: 1, user_id: User.find(1).id, subject_id: subject.id, operator_id: operator.id, value_id: value.id})
end
