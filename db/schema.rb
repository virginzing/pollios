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

ActiveRecord::Schema.define(version: 20140715111649) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "apn_apps", force: true do |t|
    t.text     "apn_dev_cert"
    t.text     "apn_prod_cert"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "apn_device_groupings", force: true do |t|
    t.integer "group_id"
    t.integer "device_id"
  end

  add_index "apn_device_groupings", ["device_id"], name: "index_apn_device_groupings_on_device_id", using: :btree
  add_index "apn_device_groupings", ["group_id", "device_id"], name: "index_apn_device_groupings_on_group_id_and_device_id", using: :btree
  add_index "apn_device_groupings", ["group_id"], name: "index_apn_device_groupings_on_group_id", using: :btree

  create_table "apn_devices", force: true do |t|
    t.string   "token",              null: false
    t.integer  "member_id"
    t.string   "api_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_registered_at"
    t.integer  "app_id"
  end

  add_index "apn_devices", ["member_id"], name: "index_apn_devices_on_member_id", using: :btree
  add_index "apn_devices", ["token", "member_id"], name: "index_apn_devices_on_token_and_member_id", unique: true, using: :btree
  add_index "apn_devices", ["token"], name: "index_apn_devices_on_token", using: :btree

  create_table "apn_group_notifications", force: true do |t|
    t.integer  "group_id",          null: false
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.text     "custom_properties"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apn_group_notifications", ["group_id"], name: "index_apn_group_notifications_on_group_id", using: :btree

  create_table "apn_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id"
  end

  create_table "apn_notifications", force: true do |t|
    t.integer  "device_id",                     null: false
    t.integer  "errors_nb",         default: 0
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "custom_properties"
  end

  add_index "apn_notifications", ["device_id"], name: "index_apn_notifications_on_device_id", using: :btree

  create_table "apn_pull_notifications", force: true do |t|
    t.integer  "app_id"
    t.string   "title"
    t.string   "content"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "launch_notification"
  end

  create_table "campaign_guests", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "guest_id"
    t.boolean  "luck"
    t.string   "serail_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaign_guests", ["campaign_id"], name: "index_campaign_guests_on_campaign_id", using: :btree
  add_index "campaign_guests", ["guest_id"], name: "index_campaign_guests_on_guest_id", using: :btree

  create_table "campaign_members", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "member_id"
    t.boolean  "luck"
    t.string   "serial_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "redeem",      default: false
    t.datetime "redeem_at"
    t.integer  "poll_id"
  end

  add_index "campaign_members", ["campaign_id"], name: "index_campaign_members_on_campaign_id", using: :btree
  add_index "campaign_members", ["member_id"], name: "index_campaign_members_on_member_id", using: :btree

  create_table "campaigns", force: true do |t|
    t.string   "name"
    t.string   "photo_campaign"
    t.integer  "used",           default: 0
    t.integer  "limit",          default: 0
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "begin_sample",   default: 1
    t.integer  "end_sample"
    t.datetime "expire"
  end

  add_index "campaigns", ["member_id"], name: "index_campaigns_on_member_id", using: :btree

  create_table "choices", force: true do |t|
    t.integer  "poll_id"
    t.string   "answer"
    t.integer  "vote",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vote_guest", default: 0
  end

  add_index "choices", ["poll_id"], name: "index_choices_on_poll_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "poll_id"
    t.integer  "member_id"
    t.string   "message"
    t.boolean  "delete_status", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["member_id"], name: "index_comments_on_member_id", using: :btree
  add_index "comments", ["poll_id"], name: "index_comments_on_poll_id", using: :btree

  create_table "companies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name", default: "CA"
  end

  create_table "devices", force: true do |t|
    t.integer  "member_id"
    t.text     "token",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "api_token"
  end

  add_index "devices", ["member_id"], name: "index_devices_on_member_id", using: :btree

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
    t.boolean  "following",    default: false
    t.boolean  "close_friend", default: false
  end

  add_index "friends", ["followed_id"], name: "index_friends_on_followed_id", using: :btree
  add_index "friends", ["follower_id", "followed_id"], name: "index_friends_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "friends", ["follower_id"], name: "index_friends_on_follower_id", using: :btree

  create_table "group_members", force: true do |t|
    t.integer  "member_id"
    t.integer  "group_id"
    t.boolean  "is_master",    default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",       default: false
    t.integer  "invite_id"
    t.boolean  "notification", default: true
  end

  add_index "group_members", ["group_id"], name: "index_group_members_on_group_id", using: :btree
  add_index "group_members", ["member_id"], name: "index_group_members_on_member_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.boolean  "public",           default: false
    t.string   "photo_group"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "member_count",     default: 0
    t.integer  "poll_count",       default: 0
    t.integer  "authorize_invite"
    t.text     "description"
  end

  create_table "guests", force: true do |t|
    t.string   "udid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hidden_polls", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hidden_polls", ["member_id"], name: "index_hidden_polls_on_member_id", using: :btree
  add_index "hidden_polls", ["poll_id"], name: "index_hidden_polls_on_poll_id", using: :btree

  create_table "history_purchases", force: true do |t|
    t.integer  "member_id"
    t.string   "product_id"
    t.string   "transaction_id"
    t.datetime "purchase_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_purchases", ["member_id"], name: "index_history_purchases_on_member_id", using: :btree
  add_index "history_purchases", ["transaction_id"], name: "index_history_purchases_on_transaction_id", unique: true, using: :btree

  create_table "history_subscriptions", force: true do |t|
    t.integer  "member_id"
    t.string   "product_id"
    t.string   "transaction_id"
    t.datetime "purchase_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_subscriptions", ["member_id"], name: "index_history_subscriptions_on_member_id", using: :btree
  add_index "history_subscriptions", ["transaction_id"], name: "index_history_subscriptions_on_transaction_id", unique: true, using: :btree

  create_table "history_view_guests", force: true do |t|
    t.integer  "guest_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_view_guests", ["guest_id"], name: "index_history_view_guests_on_guest_id", using: :btree
  add_index "history_view_guests", ["poll_id"], name: "index_history_view_guests_on_poll_id", using: :btree

  create_table "history_views", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_views", ["member_id"], name: "index_history_views_on_member_id", using: :btree
  add_index "history_views", ["poll_id"], name: "index_history_views_on_poll_id", using: :btree

  create_table "history_vote_guests", force: true do |t|
    t.integer  "guest_id"
    t.integer  "poll_id"
    t.integer  "choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_vote_guests", ["guest_id"], name: "index_history_vote_guests_on_guest_id", using: :btree
  add_index "history_vote_guests", ["poll_id"], name: "index_history_vote_guests_on_poll_id", using: :btree

  create_table "history_votes", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.integer  "choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poll_series_id", default: 0
  end

  add_index "history_votes", ["member_id"], name: "index_history_votes_on_member_id", using: :btree
  add_index "history_votes", ["poll_id"], name: "index_history_votes_on_poll_id", using: :btree

  create_table "invite_codes", force: true do |t|
    t.string   "code"
    t.boolean  "used",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "group_id"
  end

  add_index "invite_codes", ["company_id"], name: "index_invite_codes_on_company_id", using: :btree
  add_index "invite_codes", ["group_id"], name: "index_invite_codes_on_group_id", using: :btree

  create_table "member_invite_codes", force: true do |t|
    t.integer  "member_id"
    t.integer  "invite_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_invite_codes", ["invite_code_id"], name: "index_member_invite_codes_on_invite_code_id", using: :btree
  add_index "member_invite_codes", ["member_id"], name: "index_member_invite_codes_on_member_id", using: :btree

  create_table "member_report_members", force: true do |t|
    t.integer  "reporter_id"
    t.integer  "reportee_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_report_members", ["reportee_id"], name: "index_member_report_members_on_reportee_id", using: :btree
  add_index "member_report_members", ["reporter_id"], name: "index_member_report_members_on_reporter_id", using: :btree

  create_table "member_report_polls", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
  end

  add_index "member_report_polls", ["member_id"], name: "index_member_report_polls_on_member_id", using: :btree
  add_index "member_report_polls", ["poll_id"], name: "index_member_report_polls_on_poll_id", using: :btree

  create_table "members", force: true do |t|
    t.string   "fullname"
    t.string   "username"
    t.string   "avatar"
    t.string   "email"
    t.integer  "gender",                     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "group_active",               default: false
    t.integer  "friend_limit"
    t.integer  "friend_count",               default: 0
    t.integer  "member_type",                default: 0
    t.date     "birthday"
    t.integer  "province_id"
    t.string   "key_color"
    t.datetime "poll_public_req_at",         default: '2014-05-12 07:38:10'
    t.datetime "poll_overall_req_at",        default: '2014-05-12 11:39:19'
    t.string   "cover"
    t.text     "description"
    t.boolean  "apn_add_friend",             default: true
    t.boolean  "apn_invite_group",           default: true
    t.boolean  "apn_poll_friend",            default: true
    t.boolean  "sync_facebook",              default: false
    t.integer  "report_power",               default: 1
    t.boolean  "anonymous",                  default: false
    t.boolean  "anonymous_public",           default: false
    t.boolean  "anonymous_friend_following", default: false
    t.boolean  "anonymous_group",            default: false
    t.integer  "report_count",               default: 0
    t.integer  "status_account",             default: 1
    t.boolean  "first_signup",               default: true
    t.integer  "point",                      default: 0
    t.boolean  "subscription",               default: false
    t.datetime "subscribe_last"
    t.datetime "subscribe_expire"
  end

  add_index "members", ["poll_overall_req_at"], name: "index_members_on_poll_overall_req_at", using: :btree
  add_index "members", ["poll_public_req_at"], name: "index_members_on_poll_public_req_at", using: :btree
  add_index "members", ["province_id"], name: "index_members_on_province_id", using: :btree
  add_index "members", ["username"], name: "index_members_on_username", using: :btree

  create_table "notify_logs", force: true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "message"
    t.text     "custom_properties"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notify_logs", ["recipient_id"], name: "index_notify_logs_on_recipient_id", using: :btree
  add_index "notify_logs", ["sender_id"], name: "index_notify_logs_on_sender_id", using: :btree

  create_table "pg_search_documents", force: true do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "poll_groups", force: true do |t|
    t.integer  "poll_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "share_poll_of_id", default: 0
    t.integer  "member_id"
  end

  add_index "poll_groups", ["group_id"], name: "index_poll_groups_on_group_id", using: :btree
  add_index "poll_groups", ["member_id"], name: "index_poll_groups_on_member_id", using: :btree
  add_index "poll_groups", ["poll_id"], name: "index_poll_groups_on_poll_id", using: :btree
  add_index "poll_groups", ["share_poll_of_id"], name: "index_poll_groups_on_share_poll_of_id", using: :btree

  create_table "poll_members", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.integer  "share_poll_of_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public"
    t.boolean  "series"
    t.datetime "expire_date"
    t.boolean  "in_group",         default: false
  end

  add_index "poll_members", ["member_id"], name: "index_poll_members_on_member_id", using: :btree
  add_index "poll_members", ["poll_id"], name: "index_poll_members_on_poll_id", using: :btree

  create_table "poll_series", force: true do |t|
    t.integer  "member_id"
    t.text     "description"
    t.integer  "number_of_poll"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vote_all",       default: 0
    t.integer  "view_all",       default: 0
    t.datetime "expire_date"
    t.datetime "start_date",     default: '2014-02-03 15:36:16'
    t.integer  "campaign_id"
    t.integer  "vote_all_guest", default: 0
    t.integer  "view_all_guest", default: 0
    t.integer  "share_count",    default: 0
    t.integer  "type_series",    default: 0
    t.integer  "type_poll"
  end

  add_index "poll_series", ["member_id"], name: "index_poll_series_on_member_id", using: :btree

  create_table "poll_series_tags", force: true do |t|
    t.integer  "poll_series_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_series_tags", ["poll_series_id"], name: "index_poll_series_tags_on_poll_series_id", using: :btree
  add_index "poll_series_tags", ["tag_id"], name: "index_poll_series_tags_on_tag_id", using: :btree

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
    t.datetime "start_date",     default: '2014-02-03 15:36:16'
    t.boolean  "series",         default: false
    t.integer  "poll_series_id"
    t.integer  "choice_count"
    t.integer  "campaign_id"
    t.integer  "vote_all_guest", default: 0
    t.integer  "view_all_guest", default: 0
    t.integer  "favorite_count", default: 0
    t.integer  "share_count",    default: 0
    t.integer  "recurring_id",   default: 0
    t.string   "in_group_ids"
    t.string   "qrcode_key"
    t.integer  "type_poll"
    t.integer  "report_count",   default: 0
    t.integer  "status_poll",    default: 0
    t.boolean  "allow_comment",  default: true
    t.integer  "comment_count",  default: 0
  end

  add_index "polls", ["member_id"], name: "index_polls_on_member_id", using: :btree
  add_index "polls", ["poll_series_id"], name: "index_polls_on_poll_series_id", using: :btree
  add_index "polls", ["recurring_id"], name: "index_polls_on_recurring_id", using: :btree

  create_table "providers", force: true do |t|
    t.string   "name"
    t.string   "pid"
    t.string   "token"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "providers", ["member_id"], name: "index_providers_on_member_id", using: :btree
  add_index "providers", ["token"], name: "index_providers_on_token", unique: true, using: :btree

  create_table "provinces", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recurrings", force: true do |t|
    t.time     "period"
    t.integer  "status"
    t.integer  "member_id"
    t.datetime "end_recur"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  add_index "recurrings", ["member_id"], name: "index_recurrings_on_member_id", using: :btree

  create_table "request_codes", force: true do |t|
    t.integer  "member_id"
    t.text     "custom_properties"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "request_codes", ["member_id"], name: "index_request_codes_on_member_id", using: :btree

  create_table "share_polls", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shared_group_id", default: 0
  end

  add_index "share_polls", ["member_id", "poll_id", "shared_group_id"], name: "index_share_polls_on_member_id_and_poll_id_and_shared_group_id", unique: true, using: :btree
  add_index "share_polls", ["member_id"], name: "index_share_polls_on_member_id", using: :btree
  add_index "share_polls", ["poll_id"], name: "index_share_polls_on_poll_id", using: :btree
  add_index "share_polls", ["shared_group_id"], name: "index_share_polls_on_shared_group_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["poll_id"], name: "index_taggings_on_poll_id", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "watcheds", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "poll_notify",    default: true
    t.boolean  "comment_notify", default: true
  end

  add_index "watcheds", ["member_id", "poll_id"], name: "index_watcheds_on_member_id_and_poll_id", unique: true, using: :btree
  add_index "watcheds", ["member_id"], name: "index_watcheds_on_member_id", using: :btree
  add_index "watcheds", ["poll_id"], name: "index_watcheds_on_poll_id", using: :btree

end
