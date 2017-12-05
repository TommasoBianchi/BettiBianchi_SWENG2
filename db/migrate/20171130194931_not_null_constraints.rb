class NotNullConstraints < ActiveRecord::Migration[5.1]
  def change
  	change_table :breaks do |t|
  		t.change :duration, :integer, null: false
  		t.change :name, :string, null: false 
  		t.change :default_time, :integer, null: false
  		t.change :start_time_slot, :integer, null: false
  		t.change :end_time_slot, :integer, null: false
  	end

  	change_table :categories do |t|
  		t.change :name, :string, null: false
  	end

  	change_table :computed_breaks do |t|
  		t.change :duration, :integer, null: false
  		t.change :name, :string, null: false 
  		t.change :computed_time, :datetime, null: false
  		t.change :start_time_slot, :datetime, null: false
  		t.change :end_time_slot, :datetime, null: false
  		t.change :is_doable, :boolean, null: false, default: true
  	end

  	change_table :constraints do |t|
  		t.change :travel_mean, :integer, null: false
  	end

  	change_table :default_locations do |t|
  		t.change :starting_hour, 'integer USING 0', null: false
  		t.change :day_of_the_week, :integer, null: false 
  		t.change :name, :string, null: false 
  	end

  	change_table :emails do |t|
  		t.change :email, :string, null: false 
  	end

  	change_table :groups do |t|
  		t.change :name, :string, null: false
  	end

  	change_table :locations do |t|
      t.change :longitude, :decimal, null: false
      t.change :latitude, :decimal, null: false
      t.change :description, :string, null: false
  	end

  	change_table :meeting_participations do |t|
      t.change :is_admin, :boolean, null: false, default: false 
      t.change :is_consistent, :boolean, null: false
      t.change :response_status, :integer, default: 0   # 0 = PENDING
  	end

    change_table :meetings do |t|
      t.change :start_date, :datetime, null: false
      t.change :end_date, :datetime, null: false
      t.change :title, :string, null: false
    end

    change_table :operators do |t|
      t.change :description, :string, null: false 
      t.change :operator, :integer, null: false
    end

    change_table :social_users do |t|
      t.change :link, :string, null: false
    end

    change_table :socials do |t|
      t.change :name, :string, null: false
      t.change :icon_path, :string, null: false
    end

    change_table :statuses do |t|
      t.change :type, :integer, null: false, default: 0   # 0 = AUTO-DECLINE
      t.change :from, :datetime, null: false 
      t.change :to, :datetime, null: false
    end

    change_table :subjects do |t|
      t.change :name, :string, null: false
    end

    change_table :travel_steps do |t|
      t.change :travel_mean, :integer, null: false
      t.change :start_time, :datetime, null: false
      t.change :end_time, :datetime, null: false
      t.change :distance, :decimal, null: false
    end

    change_table :travels do |t|
      t.change :travel_mean, :integer, null: false
      t.change :start_time, :datetime, null: false
      t.change :end_time, :datetime, null: false
      t.change :distance, :decimal, null: false
    end

    change_table :users do |t|
      t.change :name, :string, null: false
      t.change :surname, :string, null: false
      t.change :nickname, :string, null: false
      t.change :password, :string, null: false
      t.change :preference_list, :string, null: false
    end

    change_table :values do |t|
      t.change :value, :string, null: false
    end
  end
end