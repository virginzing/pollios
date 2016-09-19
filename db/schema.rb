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

ActiveRecord::Schema.define(version: 20160805083443) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "access_webs", force: true do |t|
    t.integer  "member_id"
    t.integer  "accessable_id"
    t.string   "accessable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_webs", ["accessable_id", "accessable_type"], name: "index_access_webs_on_accessable_id_and_accessable_type", using: :btree
  add_index "access_webs", ["member_id"], name: "index_access_webs_on_member_id", using: :btree

  create_table "activity_feeds", force: true do |t|
    t.integer  "member_id"
    t.string   "action"
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_feeds", ["group_id"], name: "index_activity_feeds_on_group_id", using: :btree
  add_index "activity_feeds", ["member_id"], name: "index_activity_feeds_on_member_id", using: :btree
  add_index "activity_feeds", ["trackable_id", "trackable_type"], name: "index_activity_feeds_on_trackable_id_and_trackable_type", using: :btree

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

  create_table "api_tokens", force: true do |t|
    t.integer  "member_id"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "app_id"
  end

  add_index "api_tokens", ["member_id"], name: "index_api_tokens_on_member_id", using: :btree
  add_index "api_tokens", ["token"], name: "index_api_tokens_on_token", using: :btree

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
    t.string   "token",                                                                     null: false
    t.integer  "member_id"
    t.string   "api_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_registered_at"
    t.integer  "app_id"
    t.boolean  "receive_notification", default: true
    t.hstore   "model",                default: {"name"=>nil, "type"=>nil, "version"=>nil}
    t.hstore   "os",                   default: {"name"=>nil, "version"=>nil}
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

  create_table "bookmarks", force: true do |t|
    t.integer  "member_id"
    t.integer  "bookmarkable_id"
    t.string   "bookmarkable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bookmarks", ["bookmarkable_id", "bookmarkable_type"], name: "index_bookmarks_on_bookmarkable_id_and_bookmarkable_type", using: :btree
  add_index "bookmarks", ["member_id"], name: "index_bookmarks_on_member_id", using: :btree

  create_table "branch_poll_series", force: true do |t|
    t.integer  "branch_id"
    t.integer  "poll_series_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "branch_poll_series", ["branch_id"], name: "index_branch_poll_series_on_branch_id", using: :btree
  add_index "branch_poll_series", ["poll_series_id"], name: "index_branch_poll_series_on_poll_series_id", using: :btree

  create_table "branch_polls", force: true do |t|
    t.integer  "poll_id"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "branch_polls", ["branch_id"], name: "index_branch_polls_on_branch_id", using: :btree
  add_index "branch_polls", ["poll_id"], name: "index_branch_polls_on_poll_id", using: :btree

  create_table "branches", force: true do |t|
    t.string   "name"
    t.text     "address"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "note"
  end

  add_index "branches", ["company_id"], name: "index_branches_on_company_id", using: :btree
  add_index "branches", ["slug"], name: "index_branches_on_slug", unique: true, using: :btree

  create_table "campaign_members", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "member_id"
    t.string   "serial_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "redeem",         default: false
    t.datetime "redeem_at"
    t.integer  "poll_id"
    t.integer  "poll_series_id"
    t.integer  "redeemer_id"
    t.string   "ref_no"
    t.boolean  "gift",           default: false
    t.integer  "reward_status"
    t.datetime "deleted_at"
    t.integer  "gift_log_id"
    t.integer  "reward_id"
  end

  add_index "campaign_members", ["campaign_id"], name: "index_campaign_members_on_campaign_id", using: :btree
  add_index "campaign_members", ["created_at"], name: "index_campaign_members_on_created_at", using: :btree
  add_index "campaign_members", ["deleted_at"], name: "index_campaign_members_on_deleted_at", using: :btree
  add_index "campaign_members", ["gift"], name: "index_campaign_members_on_gift", where: "(gift = true)", using: :btree
  add_index "campaign_members", ["gift_log_id"], name: "index_campaign_members_on_gift_log_id", using: :btree
  add_index "campaign_members", ["member_id"], name: "index_campaign_members_on_member_id", using: :btree
  add_index "campaign_members", ["poll_id"], name: "index_campaign_members_on_poll_id", using: :btree
  add_index "campaign_members", ["poll_series_id"], name: "index_campaign_members_on_poll_series_id", using: :btree
  add_index "campaign_members", ["redeem"], name: "index_campaign_members_on_redeem", using: :btree
  add_index "campaign_members", ["redeem_at"], name: "index_campaign_members_on_redeem_at", using: :btree
  add_index "campaign_members", ["redeemer_id"], name: "index_campaign_members_on_redeemer_id", using: :btree
  add_index "campaign_members", ["ref_no"], name: "index_campaign_members_on_ref_no", unique: true, using: :btree
  add_index "campaign_members", ["reward_status"], name: "index_campaign_members_on_reward_status", where: "(reward_status = 0)", using: :btree
  add_index "campaign_members", ["serial_code"], name: "index_campaign_members_on_serial_code", unique: true, using: :btree

  create_table "campaigns", force: true do |t|
    t.string   "name"
    t.string   "photo_campaign"
    t.integer  "used",            default: 0
    t.integer  "limit",           default: 0
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "begin_sample",    default: 1
    t.integer  "end_sample"
    t.datetime "expire"
    t.text     "description"
    t.text     "how_to_redeem"
    t.integer  "company_id"
    t.integer  "type_campaign"
    t.boolean  "redeem_myself",   default: false
    t.hstore   "reward_info"
    t.datetime "reward_expire"
    t.boolean  "system_campaign", default: false
    t.datetime "announce_on"
  end

  add_index "campaigns", ["company_id"], name: "index_campaigns_on_company_id", using: :btree
  add_index "campaigns", ["member_id"], name: "index_campaigns_on_member_id", using: :btree
  add_index "campaigns", ["redeem_myself"], name: "index_campaigns_on_redeem_myself", where: "(redeem_myself = true)", using: :btree
  add_index "campaigns", ["reward_info"], name: "index_campaigns_on_reward_info", using: :gist
  add_index "campaigns", ["system_campaign"], name: "index_campaigns_on_system_campaign", where: "(system_campaign = true)", using: :btree
  add_index "campaigns", ["type_campaign"], name: "index_campaigns_on_type_campaign", where: "(type_campaign = 1)", using: :btree

  create_table "choices", force: true do |t|
    t.integer  "poll_id"
    t.string   "answer"
    t.integer  "vote",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vote_guest", default: 0
    t.boolean  "correct",    default: false
  end

  add_index "choices", ["poll_id"], name: "index_choices_on_poll_id", using: :btree

  create_table "collection_poll_branches", force: true do |t|
    t.integer  "branch_id"
    t.integer  "collection_poll_id"
    t.integer  "poll_series_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collection_poll_branches", ["branch_id"], name: "index_collection_poll_branches_on_branch_id", using: :btree
  add_index "collection_poll_branches", ["collection_poll_id"], name: "index_collection_poll_branches_on_collection_poll_id", using: :btree
  add_index "collection_poll_branches", ["poll_series_id"], name: "index_collection_poll_branches_on_poll_series_id", using: :btree

  create_table "collection_poll_series", force: true do |t|
    t.string   "title"
    t.integer  "company_id"
    t.integer  "sum_view_all",              default: 0
    t.integer  "sum_vote_all",              default: 0
    t.string   "questions",                 default: [],   array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feedback_recurring_id"
    t.boolean  "recurring_status",          default: true
    t.string   "recurring_poll_series_set", default: [],   array: true
    t.string   "main_poll_series",          default: [],   array: true
    t.boolean  "feedback_status",           default: true
    t.integer  "campaign_id"
  end

  add_index "collection_poll_series", ["campaign_id"], name: "index_collection_poll_series_on_campaign_id", using: :btree
  add_index "collection_poll_series", ["company_id"], name: "index_collection_poll_series_on_company_id", using: :btree
  add_index "collection_poll_series", ["feedback_recurring_id"], name: "index_collection_poll_series_on_feedback_recurring_id", using: :btree

  create_table "collection_poll_series_branches", force: true do |t|
    t.integer  "collection_poll_series_id"
    t.integer  "branch_id"
    t.integer  "poll_series_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collection_poll_series_branches", ["branch_id"], name: "index_collection_poll_series_branches_on_branch_id", using: :btree
  add_index "collection_poll_series_branches", ["collection_poll_series_id"], name: "by_series_and_branch", using: :btree
  add_index "collection_poll_series_branches", ["poll_series_id"], name: "index_collection_poll_series_branches_on_poll_series_id", using: :btree

  create_table "collection_polls", force: true do |t|
    t.string   "title"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sum_view_all", default: 0
    t.integer  "sum_vote_all", default: 0
    t.string   "questions",    default: [], array: true
  end

  add_index "collection_polls", ["company_id"], name: "index_collection_polls_on_company_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "poll_id"
    t.integer  "member_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "report_count", default: 0
    t.boolean  "ban",          default: false
    t.datetime "deleted_at"
  end

  add_index "comments", ["ban"], name: "index_comments_on_ban", where: "(ban = true)", using: :btree
  add_index "comments", ["created_at"], name: "index_comments_on_created_at", using: :btree
  add_index "comments", ["deleted_at"], name: "index_comments_on_deleted_at", using: :btree
  add_index "comments", ["member_id"], name: "index_comments_on_member_id", using: :btree
  add_index "comments", ["poll_id"], name: "index_comments_on_poll_id", using: :btree

  create_table "companies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name",       default: "CA"
    t.integer  "member_id"
    t.string   "address"
    t.string   "telephone_number"
    t.integer  "max_invite_code",  default: 0
    t.integer  "internal_poll",    default: 0
    t.string   "using_service",    default: [],    array: true
    t.boolean  "company_admin",    default: false
  end

  add_index "companies", ["member_id"], name: "index_companies_on_member_id", using: :btree
  add_index "companies", ["using_service"], name: "index_companies_on_using_service", using: :gin

  create_table "company_members", force: true do |t|
    t.integer  "company_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "company_members", ["company_id"], name: "index_company_members_on_company_id", using: :btree

  create_table "feedback_recurrings", force: true do |t|
    t.integer  "company_id"
    t.time     "period"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedback_recurrings", ["company_id"], name: "index_feedback_recurrings_on_company_id", using: :btree

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

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

  add_index "friends", ["block"], name: "index_friends_on_block", where: "(block = true)", using: :btree
  add_index "friends", ["followed_id"], name: "index_friends_on_followed_id", using: :btree
  add_index "friends", ["follower_id", "followed_id"], name: "index_friends_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "friends", ["follower_id"], name: "index_friends_on_follower_id", using: :btree

  create_table "gift_logs", force: true do |t|
    t.integer  "admin_id"
    t.integer  "campaign_id"
    t.string   "message"
    t.text     "list_member", default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_action_logs", force: true do |t|
    t.integer  "group_id"
    t.integer  "taker_id"
    t.integer  "takee_id"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_action_logs", ["group_id"], name: "index_group_action_logs_on_group_id", using: :btree

  create_table "group_companies", force: true do |t|
    t.integer  "group_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "main_group", default: false
  end

  add_index "group_companies", ["company_id"], name: "index_group_companies_on_company_id", using: :btree
  add_index "group_companies", ["group_id"], name: "index_group_companies_on_group_id", using: :btree

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

  add_index "group_members", ["active"], name: "index_group_members_on_active", using: :btree
  add_index "group_members", ["group_id"], name: "index_group_members_on_group_id", using: :btree
  add_index "group_members", ["invite_id"], name: "index_group_members_on_invite_id", using: :btree
  add_index "group_members", ["is_master"], name: "index_group_members_on_is_master", where: "(is_master = true)", using: :btree
  add_index "group_members", ["member_id", "group_id"], name: "index_group_members_on_member_id_and_group_id", unique: true, using: :btree
  add_index "group_members", ["member_id"], name: "index_group_members_on_member_id", using: :btree

  create_table "group_surveyors", force: true do |t|
    t.integer  "group_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_surveyors", ["group_id"], name: "index_group_surveyors_on_group_id", using: :btree
  add_index "group_surveyors", ["member_id"], name: "index_group_surveyors_on_member_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.boolean  "public",           default: false
    t.string   "photo_group"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authorize_invite"
    t.text     "description"
    t.boolean  "leave_group",      default: true
    t.integer  "group_type"
    t.string   "cover"
    t.boolean  "admin_post_only",  default: false
    t.boolean  "need_approve",     default: true
    t.string   "public_id"
    t.boolean  "visible",          default: true
    t.boolean  "system_group",     default: false
    t.boolean  "virtual_group",    default: false
    t.integer  "member_id"
    t.string   "cover_preset",     default: "0"
    t.boolean  "exclusive",        default: false
    t.datetime "deleted_at"
    t.boolean  "opened",           default: false
  end

  add_index "groups", ["deleted_at"], name: "index_groups_on_deleted_at", using: :btree
  add_index "groups", ["exclusive"], name: "index_groups_on_exclusive", where: "(exclusive = true)", using: :btree
  add_index "groups", ["group_type"], name: "index_groups_on_group_type", where: "(group_type = 1)", using: :btree
  add_index "groups", ["member_id"], name: "index_groups_on_member_id", using: :btree
  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree
  add_index "groups", ["need_approve"], name: "index_groups_on_need_approve", where: "(need_approve = false)", using: :btree
  add_index "groups", ["opened"], name: "index_groups_on_opened", using: :btree
  add_index "groups", ["public_id"], name: "index_groups_on_public_id", using: :btree
  add_index "groups", ["system_group"], name: "index_groups_on_system_group", where: "(system_group = true)", using: :btree

  create_table "guests", force: true do |t|
    t.string   "udid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "history_promote_polls", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_promote_polls", ["member_id"], name: "index_history_promote_polls_on_member_id", using: :btree
  add_index "history_promote_polls", ["poll_id"], name: "index_history_promote_polls_on_poll_id", using: :btree

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

  create_table "history_view_guests", force: true do |t|
    t.integer  "guest_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_view_guests", ["guest_id"], name: "index_history_view_guests_on_guest_id", using: :btree
  add_index "history_view_guests", ["poll_id"], name: "index_history_view_guests_on_poll_id", using: :btree

  create_table "history_view_questionnaires", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_series_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_view_questionnaires", ["member_id", "poll_series_id"], name: "by_member_and_poll_series", unique: true, using: :btree
  add_index "history_view_questionnaires", ["member_id"], name: "index_history_view_questionnaires_on_member_id", using: :btree
  add_index "history_view_questionnaires", ["poll_series_id"], name: "index_history_view_questionnaires_on_poll_series_id", using: :btree

  create_table "history_views", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "history_views", ["member_id", "poll_id"], name: "index_history_views_on_member_id_and_poll_id", unique: true, using: :btree
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
    t.hstore   "data_analysis"
    t.integer  "surveyor_id"
    t.boolean  "show_result",    default: false
  end

  add_index "history_votes", ["choice_id"], name: "index_history_votes_on_choice_id", using: :btree
  add_index "history_votes", ["data_analysis"], name: "index_history_votes_on_data_analysis", using: :gist
  add_index "history_votes", ["member_id"], name: "index_history_votes_on_member_id", using: :btree
  add_index "history_votes", ["poll_id"], name: "index_history_votes_on_poll_id", using: :btree
  add_index "history_votes", ["poll_series_id"], name: "index_history_votes_on_poll_series_id", using: :btree
  add_index "history_votes", ["show_result"], name: "index_history_votes_on_show_result", where: "(show_result = true)", using: :btree
  add_index "history_votes", ["surveyor_id"], name: "index_history_votes_on_surveyor_id", using: :btree

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

  create_table "invites", force: true do |t|
    t.integer  "member_id"
    t.string   "email"
    t.integer  "invitee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invites", ["member_id"], name: "index_invites_on_member_id", using: :btree

  create_table "leave_group_logs", force: true do |t|
    t.integer  "member_id"
    t.integer  "group_id"
    t.datetime "leaved_at"
    t.boolean  "receive_invite", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leave_group_logs", ["group_id"], name: "index_leave_group_logs_on_group_id", using: :btree
  add_index "leave_group_logs", ["member_id"], name: "index_leave_group_logs_on_member_id", using: :btree

  create_table "member_agree_comments", force: true do |t|
    t.integer  "member_id"
    t.integer  "comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_agree_comments", ["comment_id"], name: "index_member_agree_comments_on_comment_id", using: :btree
  add_index "member_agree_comments", ["member_id"], name: "index_member_agree_comments_on_member_id", using: :btree

  create_table "member_invite_codes", force: true do |t|
    t.integer  "member_id"
    t.integer  "invite_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_invite_codes", ["invite_code_id"], name: "index_member_invite_codes_on_invite_code_id", using: :btree
  add_index "member_invite_codes", ["member_id"], name: "index_member_invite_codes_on_member_id", using: :btree

  create_table "member_recent_requests", force: true do |t|
    t.integer  "member_id"
    t.integer  "recent_id"
    t.string   "recent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_recent_requests", ["member_id"], name: "index_member_recent_requests_on_member_id", using: :btree
  add_index "member_recent_requests", ["recent_id", "recent_type"], name: "index_member_recent_requests_on_recent_id_and_recent_type", using: :btree

  create_table "member_report_comments", force: true do |t|
    t.integer  "member_id"
    t.integer  "poll_id"
    t.integer  "comment_id"
    t.text     "message"
    t.text     "message_preset"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_report_comments", ["comment_id"], name: "index_member_report_comments_on_comment_id", using: :btree
  add_index "member_report_comments", ["member_id"], name: "index_member_report_comments_on_member_id", using: :btree
  add_index "member_report_comments", ["poll_id"], name: "index_member_report_comments_on_poll_id", using: :btree

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
    t.string   "message_preset"
  end

  add_index "member_report_polls", ["member_id"], name: "index_member_report_polls_on_member_id", using: :btree
  add_index "member_report_polls", ["poll_id"], name: "index_member_report_polls_on_poll_id", using: :btree

  create_table "member_un_recomments", force: true do |t|
    t.integer  "member_id"
    t.integer  "unrecomment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_un_recomments", ["member_id"], name: "index_member_un_recomments_on_member_id", using: :btree

  create_table "members", force: true do |t|
    t.string   "fullname"
    t.string   "username"
    t.string   "avatar"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "friend_limit"
    t.integer  "member_type",                default: 0
    t.string   "key_color"
    t.string   "cover"
    t.text     "description"
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
    t.boolean  "bypass_invite",              default: false
    t.string   "auth_token"
    t.boolean  "approve_brand",              default: false
    t.boolean  "approve_company",            default: false
    t.integer  "gender"
    t.integer  "province"
    t.date     "birthday"
    t.text     "interests"
    t.integer  "salary"
    t.hstore   "setting"
    t.boolean  "update_personal",            default: false
    t.integer  "notification_count",         default: 0
    t.integer  "request_count",              default: 0
    t.string   "cover_preset",               default: "0"
    t.integer  "register",                   default: 0
    t.string   "slug"
    t.string   "public_id"
    t.boolean  "waiting",                    default: false
    t.boolean  "created_company",            default: false
    t.boolean  "first_setting_anonymous",    default: true
    t.boolean  "receive_notify",             default: true
    t.string   "fb_id"
    t.datetime "blacklist_last_at"
    t.integer  "blacklist_count",            default: 0
    t.datetime "ban_last_at"
    t.datetime "sync_fb_last_at"
    t.string   "list_fb_id",                 default: [],                 array: true
    t.boolean  "show_recommend",             default: false
    t.hstore   "notification",               default: {},    null: false
    t.boolean  "show_search",                default: true
    t.integer  "polls_count",                default: 0
    t.integer  "history_votes_count",        default: 0
  end

  add_index "members", ["fb_id"], name: "index_members_on_fb_id", using: :btree
  add_index "members", ["first_signup"], name: "index_members_on_first_signup", where: "(first_signup = true)", using: :btree
  add_index "members", ["fullname"], name: "index_members_on_fullname", using: :btree
  add_index "members", ["member_type"], name: "index_members_on_member_type", where: "(member_type = 3)", using: :btree
  add_index "members", ["notification"], name: "index_members_on_notification", using: :gist
  add_index "members", ["public_id"], name: "index_members_on_public_id", using: :btree
  add_index "members", ["setting"], name: "index_members_on_setting", using: :gist
  add_index "members", ["show_recommend"], name: "index_members_on_show_recommend", where: "(show_recommend = true)", using: :btree
  add_index "members", ["slug"], name: "index_members_on_slug", unique: true, using: :btree
  add_index "members", ["status_account"], name: "index_members_on_status_account", where: "(status_account = 0)", using: :btree
  add_index "members", ["subscription"], name: "index_members_on_subscription", where: "(subscription = true)", using: :btree
  add_index "members", ["sync_facebook"], name: "index_members_on_sync_facebook", where: "(sync_facebook = true)", using: :btree
  add_index "members", ["update_personal"], name: "index_members_on_update_personal", where: "(update_personal = true)", using: :btree
  add_index "members", ["username"], name: "index_members_on_username", using: :btree

  create_table "members_roles", id: false, force: true do |t|
    t.integer "member_id"
    t.integer "role_id"
  end

  add_index "members_roles", ["member_id", "role_id"], name: "index_members_roles_on_member_id_and_role_id", using: :btree

  create_table "mentions", force: true do |t|
    t.integer  "comment_id"
    t.integer  "mentioner_id"
    t.string   "mentioner_name"
    t.integer  "mentionable_id"
    t.string   "mentionable_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mentions", ["comment_id"], name: "index_mentions_on_comment_id", using: :btree
  add_index "mentions", ["mentioner_id", "mentionable_id"], name: "index_mentions_on_mentioner_id_and_mentionable_id", using: :btree

  create_table "message_logs", force: true do |t|
    t.integer  "admin_id"
    t.string   "message"
    t.text     "list_member", default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "not_interested_polls", force: true do |t|
    t.integer  "member_id"
    t.integer  "unseeable_id"
    t.string   "unseeable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "not_interested_polls", ["member_id", "unseeable_id"], name: "index_not_interested_polls_on_member_id_and_unseeable_id", unique: true, using: :btree
  add_index "not_interested_polls", ["member_id"], name: "index_not_interested_polls_on_member_id", using: :btree
  add_index "not_interested_polls", ["unseeable_id", "unseeable_type"], name: "index_not_interested_polls_on_unseeable_id_and_unseeable_type", using: :btree

  create_table "notify_logs", force: true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "message"
    t.text     "custom_properties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "notify_logs", ["custom_properties"], name: "index_notify_logs_on_custom_properties", using: :btree
  add_index "notify_logs", ["recipient_id"], name: "index_notify_logs_on_recipient_id", using: :btree
  add_index "notify_logs", ["sender_id"], name: "index_notify_logs_on_sender_id", using: :btree

  create_table "pg_search_documents", force: true do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "poll_attachments", force: true do |t|
    t.integer  "poll_id"
    t.string   "image"
    t.integer  "order_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_attachments", ["order_image"], name: "index_poll_attachments_on_order_image", using: :btree
  add_index "poll_attachments", ["poll_id"], name: "index_poll_attachments_on_poll_id", using: :btree

  create_table "poll_companies", force: true do |t|
    t.integer  "poll_id"
    t.integer  "company_id"
    t.string   "post_from"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_companies", ["company_id"], name: "index_poll_companies_on_company_id", using: :btree
  add_index "poll_companies", ["poll_id"], name: "index_poll_companies_on_poll_id", using: :btree

  create_table "poll_groups", force: true do |t|
    t.integer  "poll_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "share_poll_of_id", default: 0
    t.integer  "member_id"
    t.datetime "deleted_at"
    t.integer  "deleted_by_id"
  end

  add_index "poll_groups", ["deleted_at"], name: "index_poll_groups_on_deleted_at", using: :btree
  add_index "poll_groups", ["deleted_by_id"], name: "index_poll_groups_on_deleted_by_id", using: :btree
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
    t.integer  "poll_series_id",   default: 0
  end

  add_index "poll_members", ["in_group"], name: "index_poll_members_on_in_group", where: "(in_group = true)", using: :btree
  add_index "poll_members", ["member_id"], name: "index_poll_members_on_member_id", using: :btree
  add_index "poll_members", ["poll_id"], name: "index_poll_members_on_poll_id", using: :btree
  add_index "poll_members", ["poll_series_id"], name: "index_poll_members_on_poll_series_id", using: :btree
  add_index "poll_members", ["public"], name: "index_poll_members_on_public", using: :btree
  add_index "poll_members", ["series"], name: "index_poll_members_on_series", where: "(series = true)", using: :btree

  create_table "poll_presets", force: true do |t|
    t.integer  "preset_id"
    t.string   "name"
    t.integer  "count",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "share_count",    default: 0
    t.integer  "type_series",    default: 0
    t.integer  "type_poll"
    t.boolean  "public",         default: true
    t.string   "in_group_ids",   default: "0"
    t.boolean  "allow_comment",  default: true
    t.integer  "comment_count",  default: 0
    t.boolean  "qr_only"
    t.string   "qrcode_key"
    t.boolean  "require_info"
    t.boolean  "in_group",       default: false
    t.integer  "recurring_id"
    t.boolean  "feedback",       default: false
    t.datetime "deleted_at"
    t.boolean  "expire_status",  default: false
    t.boolean  "close_status",   default: false
  end

  add_index "poll_series", ["allow_comment"], name: "index_poll_series_on_allow_comment", where: "(allow_comment = false)", using: :btree
  add_index "poll_series", ["campaign_id"], name: "index_poll_series_on_campaign_id", using: :btree
  add_index "poll_series", ["close_status"], name: "index_poll_series_on_close_status", using: :btree
  add_index "poll_series", ["deleted_at"], name: "index_poll_series_on_deleted_at", using: :btree
  add_index "poll_series", ["expire_status"], name: "index_poll_series_on_expire_status", where: "(expire_status = true)", using: :btree
  add_index "poll_series", ["feedback"], name: "index_poll_series_on_feedback", using: :btree
  add_index "poll_series", ["in_group"], name: "index_poll_series_on_in_group", where: "(in_group = true)", using: :btree
  add_index "poll_series", ["member_id"], name: "index_poll_series_on_member_id", using: :btree
  add_index "poll_series", ["public"], name: "index_poll_series_on_public", using: :btree
  add_index "poll_series", ["qr_only"], name: "index_poll_series_on_qr_only", where: "(qr_only = true)", using: :btree
  add_index "poll_series", ["qrcode_key"], name: "index_poll_series_on_qrcode_key", using: :btree
  add_index "poll_series", ["recurring_id"], name: "index_poll_series_on_recurring_id", using: :btree
  add_index "poll_series", ["require_info"], name: "index_poll_series_on_require_info", using: :btree
  add_index "poll_series", ["type_poll"], name: "index_poll_series_on_type_poll", using: :btree
  add_index "poll_series", ["type_series"], name: "index_poll_series_on_type_series", using: :btree

  create_table "poll_series_companies", force: true do |t|
    t.integer  "poll_series_id"
    t.integer  "company_id"
    t.string   "post_from"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_series_companies", ["company_id"], name: "index_poll_series_companies_on_company_id", using: :btree
  add_index "poll_series_companies", ["poll_series_id"], name: "index_poll_series_companies_on_poll_series_id", using: :btree

  create_table "poll_series_groups", force: true do |t|
    t.integer  "poll_series_id"
    t.integer  "group_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_series_groups", ["group_id"], name: "index_poll_series_groups_on_group_id", using: :btree
  add_index "poll_series_groups", ["member_id"], name: "index_poll_series_groups_on_member_id", using: :btree
  add_index "poll_series_groups", ["poll_series_id"], name: "index_poll_series_groups_on_poll_series_id", using: :btree

  create_table "poll_series_tags", force: true do |t|
    t.integer  "poll_series_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_series_tags", ["poll_series_id"], name: "index_poll_series_tags_on_poll_series_id", using: :btree
  add_index "poll_series_tags", ["tag_id"], name: "index_poll_series_tags_on_tag_id", using: :btree

  create_table "pollios_apps", force: true do |t|
    t.string   "name"
    t.string   "app_id"
    t.date     "expired_at"
    t.integer  "platform",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "polls", force: true do |t|
    t.integer  "member_id"
    t.text     "title"
    t.boolean  "public",                  default: false
    t.integer  "vote_all",                default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_poll"
    t.datetime "expire_date"
    t.integer  "view_all",                default: 0
    t.datetime "start_date",              default: '2014-02-03 15:36:16'
    t.boolean  "series",                  default: false
    t.integer  "poll_series_id"
    t.integer  "choice_count"
    t.integer  "campaign_id"
    t.integer  "share_count",             default: 0
    t.integer  "recurring_id",            default: 0
    t.string   "in_group_ids"
    t.string   "qrcode_key"
    t.integer  "type_poll"
    t.integer  "report_count",            default: 0
    t.integer  "status_poll",             default: 0
    t.boolean  "allow_comment",           default: true
    t.integer  "comment_count",           default: 0
    t.string   "member_type"
    t.boolean  "qr_only"
    t.boolean  "require_info"
    t.boolean  "expire_status",           default: false
    t.boolean  "creator_must_vote",       default: true
    t.boolean  "in_group",                default: false
    t.boolean  "show_result",             default: true
    t.integer  "order_poll",              default: 1
    t.boolean  "quiz",                    default: false
    t.integer  "notify_state",            default: 0
    t.datetime "notify_state_at"
    t.integer  "priority"
    t.integer  "thumbnail_type",          default: 0
    t.integer  "comment_notify_state",    default: 0
    t.datetime "comment_notify_state_at"
    t.boolean  "draft",                   default: false
    t.boolean  "system_poll",             default: false
    t.datetime "deleted_at"
    t.boolean  "close_status",            default: false
  end

  add_index "polls", ["allow_comment"], name: "index_polls_on_allow_comment", where: "(allow_comment = false)", using: :btree
  add_index "polls", ["campaign_id"], name: "index_polls_on_campaign_id", using: :btree
  add_index "polls", ["close_status"], name: "index_polls_on_close_status", using: :btree
  add_index "polls", ["created_at"], name: "index_polls_on_created_at", using: :btree
  add_index "polls", ["deleted_at"], name: "index_polls_on_deleted_at", using: :btree
  add_index "polls", ["expire_status"], name: "index_polls_on_expire_status", where: "(expire_status = true)", using: :btree
  add_index "polls", ["in_group"], name: "index_polls_on_in_group", where: "(in_group = true)", using: :btree
  add_index "polls", ["member_id"], name: "index_polls_on_member_id", using: :btree
  add_index "polls", ["member_type"], name: "index_polls_on_member_type", using: :btree
  add_index "polls", ["order_poll"], name: "index_polls_on_order_poll", using: :btree
  add_index "polls", ["poll_series_id"], name: "index_polls_on_poll_series_id", using: :btree
  add_index "polls", ["public"], name: "index_polls_on_public", using: :btree
  add_index "polls", ["qr_only"], name: "index_polls_on_qr_only", where: "(qr_only = true)", using: :btree
  add_index "polls", ["qrcode_key"], name: "index_polls_on_qrcode_key", using: :btree
  add_index "polls", ["recurring_id"], name: "index_polls_on_recurring_id", using: :btree
  add_index "polls", ["require_info"], name: "index_polls_on_require_info", where: "(require_info = true)", using: :btree
  add_index "polls", ["series"], name: "index_polls_on_series", where: "(series = true)", using: :btree
  add_index "polls", ["status_poll"], name: "index_polls_on_status_poll", where: "(status_poll = '-1'::integer)", using: :btree
  add_index "polls", ["system_poll"], name: "index_polls_on_system_poll", where: "(system_poll = true)", using: :btree
  add_index "polls", ["type_poll"], name: "index_polls_on_type_poll", using: :btree

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
    t.integer  "company_id"
  end

  add_index "recurrings", ["member_id"], name: "index_recurrings_on_member_id", using: :btree

  create_table "redeemers", force: true do |t|
    t.integer  "company_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redeemers", ["company_id"], name: "index_redeemers_on_company_id", using: :btree
  add_index "redeemers", ["member_id"], name: "index_redeemers_on_member_id", using: :btree

  create_table "request_codes", force: true do |t|
    t.integer  "member_id"
    t.text     "custom_properties"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "request_codes", ["member_id"], name: "index_request_codes_on_member_id", using: :btree

  create_table "request_groups", force: true do |t|
    t.integer  "member_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "accepter_id"
    t.boolean  "accepted",    default: false
  end

  add_index "request_groups", ["group_id"], name: "index_request_groups_on_group_id", using: :btree
  add_index "request_groups", ["member_id"], name: "index_request_groups_on_member_id", using: :btree

  create_table "rewards", force: true do |t|
    t.integer  "campaign_id"
    t.string   "title"
    t.text     "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reward_expire"
    t.integer  "total"
    t.integer  "claimed"
    t.integer  "odds"
    t.datetime "expire_at"
    t.text     "redeem_instruction"
    t.boolean  "self_redeem"
    t.hstore   "options"
  end

  add_index "rewards", ["campaign_id"], name: "index_rewards_on_campaign_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "rpush_apps", force: true do |t|
    t.string   "name",                                null: false
    t.string   "environment"
    t.text     "certificate"
    t.string   "password"
    t.integer  "connections",             default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                null: false
    t.string   "auth_key"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", force: true do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id"
  end

  add_index "rpush_feedback", ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree

  create_table "rpush_notifications", force: true do |t|
    t.integer  "badge"
    t.string   "device_token",      limit: 64
    t.string   "sound",                        default: "default"
    t.text     "alert"
    t.text     "data"
    t.integer  "expiry",                       default: 86400
    t.boolean  "delivered",                    default: false,     null: false
    t.datetime "delivered_at"
    t.boolean  "failed",                       default: false,     null: false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "alert_is_json",                default: false
    t.string   "type",                                             null: false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",             default: false,     null: false
    t.text     "registration_ids"
    t.integer  "app_id",                                           null: false
    t.integer  "retries",                      default: 0
    t.string   "uri"
    t.datetime "fail_after"
    t.boolean  "processing",                   default: false,     null: false
    t.integer  "priority"
    t.text     "url_args"
    t.string   "category"
    t.boolean  "content_available",            default: false
    t.text     "notification"
  end

  add_index "rpush_notifications", ["delivered", "failed"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))", using: :btree

  create_table "save_poll_laters", force: true do |t|
    t.integer  "member_id"
    t.integer  "savable_id"
    t.string   "savable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "save_poll_laters", ["member_id", "savable_id"], name: "index_save_poll_laters_on_member_id_and_savable_id", unique: true, using: :btree
  add_index "save_poll_laters", ["member_id"], name: "index_save_poll_laters_on_member_id", using: :btree
  add_index "save_poll_laters", ["savable_id", "savable_type"], name: "index_save_poll_laters_on_savable_id_and_savable_type", using: :btree

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

  create_table "special_qrcodes", force: true do |t|
    t.string   "code"
    t.hstore   "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suggest_groups", force: true do |t|
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suggests", force: true do |t|
    t.integer  "poll_series_id"
    t.integer  "member_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suggests", ["member_id"], name: "index_suggests_on_member_id", using: :btree
  add_index "suggests", ["poll_series_id"], name: "index_suggests_on_poll_series_id", using: :btree

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

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "triggers", force: true do |t|
    t.integer  "triggerable_id"
    t.string   "triggerable_type"
    t.hstore   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "triggers", ["data"], name: "index_triggers_on_data", using: :gist
  add_index "triggers", ["triggerable_id", "triggerable_type"], name: "index_triggers_on_triggerable_id_and_triggerable_type", using: :btree

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

  add_index "watcheds", ["comment_notify"], name: "index_watcheds_on_comment_notify", using: :btree
  add_index "watcheds", ["member_id", "poll_id"], name: "index_watcheds_on_member_id_and_poll_id", unique: true, using: :btree
  add_index "watcheds", ["member_id"], name: "index_watcheds_on_member_id", using: :btree
  add_index "watcheds", ["poll_id"], name: "index_watcheds_on_poll_id", using: :btree
  add_index "watcheds", ["poll_notify"], name: "index_watcheds_on_poll_notify", using: :btree

end
