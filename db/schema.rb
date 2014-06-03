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

ActiveRecord::Schema.define(version: 20140603015820) do

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "order"
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
  end

  create_table "tokens", force: true do |t|
    t.string   "token"
    t.integer  "user_id"
    t.integer  "tokenable_id"
    t.string   "tokenable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unposts", force: true do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.integer  "condition_id"
    t.string   "title"
    t.text     "description"
    t.string   "keyword1"
    t.string   "keyword2"
    t.string   "keyword3"
    t.string   "keyword4"
    t.string   "link"
    t.integer  "price"
    t.boolean  "travel"
    t.integer  "distance"
    t.integer  "zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "username"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed"
    t.string   "role"
  end

end