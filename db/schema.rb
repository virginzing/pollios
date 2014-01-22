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

ActiveRecord::Schema.define(version: 20140122061535) do

  create_table "choices", force: true do |t|
    t.integer  "poll_id"
    t.string   "answer"
    t.integer  "vote",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "choices", ["poll_id"], name: "index_choices_on_poll_id"

  create_table "friends", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",      default: 0
  end

  add_index "friends", ["followed_id"], name: "index_friends_on_followed_id"
  add_index "friends", ["follower_id", "followed_id"], name: "index_friends_on_follower_id_and_followed_id", unique: true
  add_index "friends", ["follower_id"], name: "index_friends_on_follower_id"

  create_table "group_members", force: true do |t|
    t.integer  "member_id"
    t.integer  "group_id"
    t.boolean  "is_master",  default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_members", ["group_id"], name: "index_group_members_on_group_id"
  add_index "group_members", ["member_id"], name: "index_group_members_on_member_id"

  create_table "groups", force: true do |t|
    t.string   "name"
    t.boolean  "publish",     default: false
    t.string   "photo_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", force: true do |t|
    t.string   "sentai_id"
    t.string   "sentai_name"
    t.string   "username"
    t.string   "avatar"
    t.string   "token"
    t.string   "email"
    t.integer  "gender",        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public_member", default: true
  end

  create_table "polls", force: true do |t|
    t.integer  "member_id"
    t.string   "title"
    t.boolean  "public",     default: false
    t.integer  "vote_all",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "polls", ["member_id"], name: "index_polls_on_member_id"

end
