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

ActiveRecord::Schema.define(version: 20171219150900) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "breaks", force: :cascade do |t|
    t.integer "duration", null: false
    t.string "name", null: false
    t.integer "day_of_the_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "default_time", null: false
    t.integer "start_time_slot", null: false
    t.integer "end_time_slot", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "superclass_id"
  end

  create_table "computed_breaks", force: :cascade do |t|
    t.datetime "computed_time", null: false
    t.datetime "start_time_slot", null: false
    t.datetime "end_time_slot", null: false
    t.integer "duration", null: false
    t.string "name", null: false
    t.boolean "is_doable", default: true, null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bit_varying "doability_bitmask", limit: 1440
    t.integer "break_id"
  end

  create_table "constraints", force: :cascade do |t|
    t.integer "travel_mean", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "subject_id"
    t.integer "operator_id"
    t.integer "value_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "from_user"
    t.integer "to_user"
  end

  create_table "default_locations", force: :cascade do |t|
    t.integer "starting_hour", null: false
    t.integer "day_of_the_week", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "location_id"
  end

  create_table "emails", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["email"], name: "index_emails_on_email", unique: true
  end

  create_table "group_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incomplete_users", force: :cascade do |t|
    t.string "password_digest", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_incomplete_users_on_email", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.decimal "longitude", null: false
    t.decimal "latitude", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meeting_participation_conflicts", force: :cascade do |t|
    t.integer "meeting_participation_1_id"
    t.integer "meeting_participation_2_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meeting_participations", force: :cascade do |t|
    t.boolean "is_admin", default: false, null: false
    t.boolean "is_consistent", null: false
    t.integer "response_status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "meeting_id"
    t.integer "arriving_travel_id"
    t.integer "leaving_travel_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.string "title", null: false
    t.text "abstract"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
  end

  create_table "operators", force: :cascade do |t|
    t.string "description", null: false
    t.integer "operator", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subject_id"
  end

  create_table "social_users", force: :cascade do |t|
    t.string "link", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "social_id"
  end

  create_table "socials", force: :cascade do |t|
    t.string "name", null: false
    t.string "icon_path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.integer "type", default: 0, null: false
    t.datetime "from", null: false
    t.datetime "to", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "travel_steps", force: :cascade do |t|
    t.integer "travel_mean", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.decimal "distance", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "travel_id"
    t.string "description", null: false
    t.string "from"
    t.string "to"
  end

  create_table "travels", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.integer "travel_mean", null: false
    t.decimal "distance", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "starting_location_dl_id"
    t.integer "ending_location_dl_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "surname", null: false
    t.string "nickname", null: false
    t.string "password_digest", null: false
    t.string "company"
    t.string "website"
    t.text "brief"
    t.string "phone_number"
    t.string "preference_list", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "primary_email_id"
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["primary_email_id"], name: "index_users_on_primary_email_id", unique: true
  end

  create_table "values", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subject_id"
  end

  add_foreign_key "breaks", "users"
  add_foreign_key "computed_breaks", "breaks"
  add_foreign_key "computed_breaks", "users"
  add_foreign_key "constraints", "\"values\"", column: "value_id"
  add_foreign_key "constraints", "operators"
  add_foreign_key "constraints", "subjects"
  add_foreign_key "constraints", "users"
  add_foreign_key "contacts", "users", column: "from_user"
  add_foreign_key "contacts", "users", column: "to_user"
  add_foreign_key "default_locations", "locations"
  add_foreign_key "default_locations", "users"
  add_foreign_key "emails", "users"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "meeting_participation_conflicts", "meeting_participations", column: "meeting_participation_1_id"
  add_foreign_key "meeting_participation_conflicts", "meeting_participations", column: "meeting_participation_2_id"
  add_foreign_key "meeting_participations", "meetings"
  add_foreign_key "meeting_participations", "travels", column: "arriving_travel_id"
  add_foreign_key "meeting_participations", "travels", column: "leaving_travel_id"
  add_foreign_key "meeting_participations", "users"
  add_foreign_key "meetings", "locations"
  add_foreign_key "operators", "subjects"
  add_foreign_key "social_users", "socials"
  add_foreign_key "social_users", "users"
  add_foreign_key "statuses", "users"
  add_foreign_key "travel_steps", "travels"
  add_foreign_key "travels", "default_locations", column: "ending_location_dl_id"
  add_foreign_key "travels", "default_locations", column: "starting_location_dl_id"
  add_foreign_key "users", "emails", column: "primary_email_id"
  add_foreign_key "values", "subjects"
end
