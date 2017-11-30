# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171130091733) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "breaks", force: :cascade do |t|
    t.integer "duration"
    t.string "name"
    t.integer "day_of_the_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "default_time"
    t.integer "start_time_slot"
    t.integer "end_time_slot"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "computed_breaks", force: :cascade do |t|
    t.datetime "computed_time"
    t.datetime "start_time_slot"
    t.datetime "end_time_slot"
    t.integer "duration"
    t.string "name"
    t.boolean "is_doable"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "constraints", force: :cascade do |t|
    t.integer "travel_mean"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "from_user"
    t.integer "to_user"
  end

  create_table "default_locations", force: :cascade do |t|
    t.time "starting_hour"
    t.integer "day_of_the_week"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "location_id"
  end

  create_table "emails", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "group_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.decimal "longitude"
    t.decimal "latitude"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meeting_participations", force: :cascade do |t|
    t.boolean "is_admin"
    t.boolean "is_consistent"
    t.integer "response_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "meeting_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "title"
    t.text "abstract"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
  end

  create_table "operators", force: :cascade do |t|
    t.string "description"
    t.integer "operator"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "social_users", force: :cascade do |t|
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "social_id"
  end

  create_table "socials", force: :cascade do |t|
    t.string "name"
    t.string "icon_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.integer "type"
    t.datetime "from"
    t.datetime "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "travel_steps", force: :cascade do |t|
    t.integer "travel_mean"
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "travel_id"
  end

  create_table "travels", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "travel_mean"
    t.decimal "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "meeting_participation_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "surname"
    t.string "nickname"
    t.string "password"
    t.string "company"
    t.string "website"
    t.text "brief"
    t.string "phone_number"
    t.string "preference_list"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "primary_email"
  end

  create_table "values", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "breaks", "users"
  add_foreign_key "computed_breaks", "users"
  add_foreign_key "constraints", "users"
  add_foreign_key "contacts", "users", column: "from_user"
  add_foreign_key "contacts", "users", column: "to_user"
  add_foreign_key "default_locations", "locations"
  add_foreign_key "default_locations", "users"
  add_foreign_key "emails", "users"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "meeting_participations", "meetings"
  add_foreign_key "meeting_participations", "users"
  add_foreign_key "meetings", "locations"
  add_foreign_key "social_users", "socials"
  add_foreign_key "social_users", "users"
  add_foreign_key "statuses", "users"
  add_foreign_key "travel_steps", "travels"
  add_foreign_key "travels", "meeting_participations"
  add_foreign_key "users", "emails", column: "primary_email"
end
