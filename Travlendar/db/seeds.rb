# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

######################################################################################################

# DUMP EVERYTHING BEFORE RE-SEEDING
ActiveRecord::Base.establish_connection
ActiveRecord::Base.connection.tables.each do |table|
  next if table == 'schema_migrations'

  # MySQL and PostgreSQL
  ActiveRecord::Base.connection.execute("TRUNCATE #{table} RESTART IDENTITY")

  # SQLite
  # ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
end
# DUMP EVERYTHING BEFORE RE-SEEDING

for i in 1..10 do
	user = User.create({name: 'Pinco' + i.to_s, surname: 'Pallo' + i.to_s, password: '0000', nickname: 'PP' + i.to_s})
end

email = Email.create({email: 'bettix44@gmail.com'}) 
