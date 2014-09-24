# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140924010345) do

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  create_table "categories_conditions", force: true do |t|
    t.integer  "category_id"
    t.integer  "condition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conditions", force: true do |t|
    t.string   "level"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  create_table "invitations", force: true do |t|
    t.integer  "user_id"
    t.string   "recipient_email"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "radius"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "city"
    t.string   "state"
    t.integer  "zipcode"
  end

  create_table "messages", force: true do |t|
    t.integer  "recipient_id"
    t.string   "subject"
    t.string   "content"
    t.string   "contact_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sender_id"
    t.string   "messageable_type"
    t.integer  "messageable_id"
    t.datetime "deleted_at"
    t.string   "slug"
    t.string   "msg_type"
  end

  create_table "preferences", force: true do |t|
    t.integer  "user_id"
    t.boolean  "hit_notifications"
    t.boolean  "safeguest_contact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questionaires", force: true do |t|
    t.integer  "user_id"
    t.text     "intuitive"
    t.text     "layout"
    t.text     "purpose"
    t.text     "making_unlistings"
    t.text     "search_browse"
    t.text     "notlike1"
    t.text     "notlike2"
    t.text     "keepit"
    t.text     "junkit"
    t.text     "breaks1"
    t.text     "breaks2"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "safeguests", force: true do |t|
    t.string   "email"
    t.boolean  "confirmed"
    t.boolean  "blacklisted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirm_token"
    t.string   "confirm_token_created_at"
  end

  create_table "settings", force: true do |t|
    t.integer  "invites_ration"
    t.integer  "invites_max"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tokens", force: true do |t|
    t.string   "token"
    t.integer  "user_id"
    t.integer  "tokenable_id"
    t.string   "tokenable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unimages", force: true do |t|
    t.integer  "unlisting_id"
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.integer  "user_id"
  end

  create_table "unlistings", force: true do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.integer  "condition_id"
    t.string   "title"
    t.text     "description"
    t.string   "keyword1"
    t.string   "keyword2"
    t.string   "keyword3"
    t.string   "keyword4"
    t.text     "link",           limit: 255
    t.integer  "price"
    t.boolean  "travel"
    t.integer  "distance"
    t.integer  "zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "inactive"
    t.string   "unimages_token"
    t.string   "slug"
    t.string   "link_image"
    t.boolean  "found"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "username"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed"
    t.string   "role"
    t.string   "prt"
    t.datetime "prt_created_at"
    t.string   "avatar"
    t.boolean  "use_avatar"
    t.integer  "invite_count"
    t.integer  "location_id"
    t.string   "slug"
    t.string   "status"
  end

end
