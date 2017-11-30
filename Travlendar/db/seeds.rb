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
NUM_USERS = 10
NUM_MEETINGS = 4

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

	user.primary_email = Email.create({email: 'Pinco' + i.to_s + '.Pallo@travlendar.com', user_id: user.id})
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
end

location = Location.create({latitude: 37.4133028, longitude: -122.1513074, description: "Mountain View"})

for i in 1..NUM_MEETINGS do
  new_start_date = DateTime.new(2017, 6+i, 29, 12, 35, 0)
  end_date = DateTime.new(2017, 6+i, 29, 14, 35, 0)
	meeting = Meeting.create({location_id: location.id, title: 'NewMeeting' + i.to_s, start_date: new_start_date, end_date: end_date})
end
