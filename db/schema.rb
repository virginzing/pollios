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

ActiveRecord::Schema.define(version: 20140203064511) do

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
    t.boolean  "active",       default: true
    t.boolean  "block",        default: false
    t.boolean  "mute",         default: false
    t.boolean  "visible_poll", default: true
    t.integer  "status"
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
    t.boolean  "active",     default: false
    t.integer  "invite_id"
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

  create_table "hidden_polls", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hidden_polls", ["member_id"], name: "index_hidden_polls_on_member_id"
  add_index "hidden_polls", ["poll_id"], name: "index_hidden_polls_on_poll_id"

  create_table "history_views", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_views", ["member_id"], name: "index_history_views_on_member_id"
  add_index "history_views", ["poll_id"], name: "index_history_views_on_poll_id"

  create_table "history_votes", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.integer  "choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_votes", ["member_id"], name: "index_history_votes_on_member_id"
  add_index "history_votes", ["poll_id"], name: "index_history_votes_on_poll_id"

  create_table "members", force: true do |t|
    t.string   "sentai_id"
    t.string   "sentai_name"
    t.string   "username"
    t.string   "avatar"
    t.string   "token"
    t.string   "email"
    t.integer  "gender",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "friend_limit"
    t.integer  "friend_count", default: 0
    t.integer  "member_type",  default: 0
    t.boolean  "group_active", default: false
    t.date     "birthday"
  end

  create_table "poll_groups", force: true do |t|
    t.integer  "poll_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_groups", ["group_id"], name: "index_poll_groups_on_group_id"
  add_index "poll_groups", ["poll_id"], name: "index_poll_groups_on_poll_id"

  create_table "poll_members", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.integer  "share_poll_of_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_members", ["member_id"], name: "index_poll_members_on_member_id"
  add_index "poll_members", ["poll_id"], name: "index_poll_members_on_poll_id"

  create_table "poll_series", force: true do |t|
    t.integer  "member_id"
    t.text     "description"
    t.integer  "number_of_poll"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vote_all",       default: 0
    t.integer  "view_all",       default: 0
    t.datetime "expire_date"
    t.datetime "start_date",     default: '2014-02-03 06:45:53'
  end

  add_index "poll_series", ["member_id"], name: "index_poll_series_on_member_id"

  create_table "polls", force: true do |t|
    t.integer  "member_id"
    t.string   "title"
    t.boolean  "public",         default: false
    t.integer  "vote_all",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_poll"
    t.datetime "expire_date"
    t.integer  "view_all",       default: 0
    t.datetime "start_date",     default: '2014-01-29 06:19:55'
    t.boolean  "series",         default: false
    t.integer  "poll_series_id"
  end

  add_index "polls", ["member_id"], name: "index_polls_on_member_id"
  add_index "polls", ["poll_series_id"], name: "index_polls_on_poll_series_id"

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["poll_id"], name: "index_taggings_on_poll_id"
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id"

  create_table "tags", force: true do |t|
    t.string   "name"
    t.integer  "tag_count",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
