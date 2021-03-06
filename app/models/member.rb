# == Schema Information
#
# Table name: members
#
#  id                         :integer          not null, primary key
#  fullname                   :string(255)
#  username                   :string(255)
#  avatar                     :string(255)
#  email                      :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  friend_limit               :integer
#  member_type                :integer          default(0)
#  key_color                  :string(255)
#  cover                      :string(255)
#  description                :text
#  sync_facebook              :boolean          default(FALSE)
#  report_power               :integer          default(1)
#  anonymous                  :boolean          default(FALSE)
#  anonymous_public           :boolean          default(FALSE)
#  anonymous_friend_following :boolean          default(FALSE)
#  anonymous_group            :boolean          default(FALSE)
#  report_count               :integer          default(0)
#  status_account             :integer          default(1)
#  first_signup               :boolean          default(TRUE)
#  point                      :integer          default(0)
#  subscription               :boolean          default(FALSE)
#  subscribe_last             :datetime
#  subscribe_expire           :datetime
#  bypass_invite              :boolean          default(FALSE)
#  auth_token                 :string(255)
#  approve_brand              :boolean          default(FALSE)
#  approve_company            :boolean          default(FALSE)
#  gender                     :integer
#  province                   :integer
#  birthday                   :date
#  interests                  :text
#  salary                     :integer
#  setting                    :hstore
#  update_personal            :boolean          default(FALSE)
#  notification_count         :integer          default(0)
#  request_count              :integer          default(0)
#  cover_preset               :string(255)      default("0")
#  register                   :integer          default(0)
#  slug                       :string(255)
#  public_id                  :string(255)
#  waiting                    :boolean          default(FALSE)
#  created_company            :boolean          default(FALSE)
#  first_setting_anonymous    :boolean          default(TRUE)
#  receive_notify             :boolean          default(TRUE)
#  fb_id                      :string(255)
#  blacklist_last_at          :datetime
#  blacklist_count            :integer          default(0)
#  ban_last_at                :datetime
#  sync_fb_last_at            :datetime
#  list_fb_id                 :string(255)      default([]), is an Array
#  show_recommend             :boolean          default(FALSE)
#  notification               :hstore           default({}), not null
#  show_search                :boolean          default(TRUE)
#  polls_count                :integer          default(0)
#  history_votes_count        :integer          default(0)
#

class Member < ActiveRecord::Base
  NEW_USER_POINT = 5
  # extend FriendlyId
  include PgSearch
  include MemberHelper
  include MemberAdmin
  attr_accessor :list_email, :file, :company_id, :redeemer, :feedback

  rolify
  # friendly_id :slug_candidates, use: [:slugged, :finders]
  # has_paper_trail

  # multisearchable :against => [:fullname, :username, :email]
  pg_search_scope :searchable_member, against: [:fullname, :email], using: { trigram: { threshold: 0.1 } }

  mount_uploader :avatar, MemberUploader
  mount_uploader :cover, MemberUploader

  serialize :interests, Array

  store_accessor :setting
  store_accessor :notification

  cattr_accessor :current_member, :reported_polls, :shared_polls, :viewed_polls, :voted_polls, :list_friend_block, :list_friend_active,
                  :list_your_request, :list_friend_request, :list_friend_following, :list_group_active, :watched_polls

  has_many :member_invite_codes, dependent: :destroy
  has_many :member_un_recomments, dependent: :destroy

  has_many :history_view_questionnaires, -> { order('history_view_questionnaires.created_at DESC') }, dependent: :destroy
  has_many :questionnaire_viewed, through: :history_view_questionnaires, source: :poll_series

  has_one :company, dependent: :destroy

  has_one :company_member, dependent: :destroy

  has_many :comments, dependent: :destroy
  has_many :history_purchases, dependent: :destroy

  has_many :watcheds, dependent: :destroy

  has_many :apn_devices, class_name: 'Apn::Device', dependent: :destroy

  has_many :sent_notifies, class_name: 'NotifyLog', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_notifies, -> { includes :sender }, class_name: 'NotifyLog', foreign_key: 'recipient_id', dependent: :destroy

  has_many :sent_reports, class_name: 'MemberReportMember', foreign_key: 'reporter_id', dependent: :destroy
  has_many :get_reportee, -> { includes :reporter }, class_name: 'MemberReportMember', foreign_key: 'reportee_id', dependent: :destroy

  # belongs_to :province, inverse_of: :members

  has_many :follower, -> { where("following = 't' AND status != 1") }, foreign_key: 'followed_id', class_name: 'Friend'
  has_many :get_follower, through: :follower, source: :follower

  has_many :following, -> { where("following = 't' AND status != 1") }, foreign_key: 'follower_id', class_name: 'Friend', dependent: :destroy
  has_many :get_following, -> { where('members.member_type = 1 OR members.member_type = 2') }, through: :following, source: :followed

  has_many :history_views, dependent: :destroy

  has_many :history_votes, dependent: :destroy

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members, source: :group
  # has_many :groups, through: :group_members, source: :group, dependent: :destroy

  has_many :group_active, -> { where('group_members.active = ?', true) }, dependent: :destroy, class_name: 'GroupMember'
  has_many :get_group_active, through: :group_active, source: :group

  has_many :group_inactive, -> { where('group_members.active = ?', false) }, dependent: :destroy, class_name: 'GroupMember'
  has_many :get_group_inactive, through: :group_inactive, source: :group


  has_many :your_request, -> { where(status: 0, active: true) }, foreign_key: 'follower_id', class_name: 'Friend'
  has_many :get_your_request, through: :your_request, source: :followed

  has_many :friend_request, -> { where(status: 2, active: true) }, foreign_key: 'follower_id', class_name: 'Friend'
  has_many :get_friend_request, through: :friend_request, source: :followed

  has_many :friends, foreign_key: 'follower_id', class_name: 'Friend', dependent: :destroy
  has_many :get_friends, through: :friends, source: :followed

  has_many :friend_active, -> { where(status: 1, active: true, block: false) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_active, through: :friend_active , source: :followed

  has_many :friend_blocked, -> { where(status: 1, active: true, block: true) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_blocked, through: :friend_blocked ,source: :followed

  has_many :muted_by_friend, -> { where(mute: true) }, foreign_key: "followed_id", class_name: "Friend"
  has_many :get_muted_by_friend, through: :muted_by_friend, source: :follower

  has_many :friend_inactive, -> { where(status: 1, active: false) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_inactive, through: :friend_inactive, source: :followed

  has_many :whitish_friend, -> { where(active: true, mute: false, visible_poll: true).having_status(:friend) }, class_name: "Friend", foreign_key: "follower_id"

  has_many :get_my_poll, -> { where("polls.series = ?", false).limit(LIMIT_POLL) }, class_name: "Poll"

  has_many :poll_members, dependent: :destroy
  has_many :polls, through: :poll_members, source: :poll

  has_many :campaigns, dependent: :destroy

  has_many :member_rewards, dependent: :destroy, class_name: "MemberReward"
  has_many :rewards, through: :member_rewards, source: :reward

  has_many :share_polls, dependent: :destroy
  has_many :recurrings, dependent: :destroy

  has_many :poll_series

  has_many :providers, dependent: :destroy

  has_many :member_report_polls, dependent: :destroy
  has_many :poll_reports, through: :member_report_polls, source: :poll

  has_many :request_codes, dependent: :destroy

  has_many :group_surveyors, dependent: :destroy

  has_many :surveyor_in_group, through: :group_surveyors, source: :group
  # after_create :set_follow_pollios

  has_many :request_groups, -> { where(accepted: false) } , dependent: :destroy
  has_many :ask_join_groups, through: :request_groups, source: :group

  has_many :activity_feeds, dependent: :destroy

  has_many :not_interested_polls

  has_many :save_poll_laters

  has_many :api_tokens, dependent: :destroy

  has_many :invites, dependent: :destroy
  has_many :members_invites, through: :invites, source: :invitee

  has_many :member_report_comments, dependent: :destroy
  has_many :comment_reports, through: :member_report_comments, source: :comment

  has_one :redeemer

  before_create :set_friend_limit

  before_update { |member| Admin::BanMember.flush_cached_ban_members if status_account_changed? }
  before_update :check_sync_facebook

  after_commit :flush_cache

  # after_create :set_public_id
  before_create :set_cover_preset
  before_create :set_description
  before_create :set_default_notification

  scope :citizen,   -> { where(member_type: 0) }
  scope :celebrity, -> { where(member_type: 1) }
  scope :receive_notify, -> { where(receive_notify: true) }

  scope :with_notification_public,  -> { where("notification @> hstore(:key, :value) OR notification @> hstore(:key_one, :value_one)", key: "public", value: "1", key_one: "public", value_one: "true") }
  scope :with_notification_friend,  -> { where("notification @> hstore(:key, :value) OR notification @> hstore(:key_one, :value_one)", key: "friend", value: "1", key_one: "friend", value_one: "true") }
  scope :with_notification_group,   -> { where("notification @> hstore(:key, :value) OR notification @> hstore(:key_one, :value_one)", key: "group", value: "1", key_one: "group", value_one: "true") }

  scope :viewing_by_member, (lambda do |viewing_member|
    incoming_block_ids = Member::MemberList.new(viewing_member).blocked_by_someone
    where('members.id NOT IN (?)', incoming_block_ids) if incoming_block_ids.count > 0
  end)

  scope :order_by_name, -> { order('LOWER(members.fullname)') }

  validates :email, presence: true, :uniqueness => { :case_sensitive => false }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, :allow_blank => true
  validates :username , :uniqueness => { :case_sensitive => false }, format: { with: /\A[a-zA-Z0-9_.]+\z/i, message: "only allows letters" }, :allow_blank => true , on: :update

  validates :public_id , :uniqueness => { :case_sensitive => false, message: "Public ID has already been taken." }, format: { with: /\A[a-zA-Z0-9_.]+\z/i, message: %(Public ID only allows symbol ("." and "_").) }, :allow_blank => true , on: :update

  validates :key_color, length: { is: 6 }, allow_blank: true

  LIMIT_POLL = 10
  FRIEND_LIMIT = 1000

  self.per_page = 20

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) do
      @member = find_by(id: id)
      fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Member::NOT_FOUND unless @member.present?
      @member
    end
  end

  def authenticated?(authen_token)
    return [false, '403 Forbidden', 403] if forbidden? 
    return [false, '401 Unauthorized: invalid token', 401] if invalid_authen_token?(authen_token)

    [true, nil]
  end

  def forbidden?
    blacklist? || ban?
  end

  def invalid_authen_token?(authen_token)
    !api_tokens.exists?(token: authen_token)
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def set_default_notification
    self.notification = Member::OldNotification::DEFAULT
  end

  def check_sync_facebook
    if fb_id_changed? && fb_id.present?
      raise ExceptionHandler::UnprocessableEntity, "This Facebook account had linked with another Pollios user." if Member.exists?(fb_id: fb_id)

      self.sync_facebook = true
      self.sync_fb_last_at = Time.zone.now
    end
  end

  def set_cover_preset
    unless self.cover.present?
      if self.cover_preset.present?
        self.cover_preset = Member.random_cover_preset unless self.cover_preset != "0"
      else
        self.cover_preset = Member.random_cover_preset
      end
    else
      self.cover_preset = "0"
    end
  end

  def set_description
    unless self.description.present?
      self.description = "Pollios User"
    end
  end

  def self.random_cover_preset
    rand(1..30).to_s
  end

  def get_company
    # if company
    #     company
    # else
    #   if company_member
    #       company_member.company
    #   else
    #     nil
    #   end
    # end
    company ? company : company_member ? company_member.company : nil
  end

  def get_public_id
    public_id || ""
  end

  # def self.alert_save_poll
  #   SavePollWorker.perform_async({})
  # end

  def self.from_omniauth(auth)
    fb_params = {
      id: auth.uid,
      provider: 'facebook',
      name: auth.info.name,
      email: auth.info.email,
      gender: auth.extra.raw_info.gender
    }

    @auth = Authentication.new(fb_params.merge(Hash["register" => :web_mobile]))

    if @auth.authenticated?
      @auth.member
    end
    @auth.member
  end

  def free_reward_first_signup
    campaign_first_signup = Campaign.where("reward_info -> 'first_signup' = ?", "true").first
    if campaign_first_signup
      reward = campaign_first_signup.free_reward(id)
    end
    reward
  end

  def create_group_surveyor(group_id)
    GroupSurveyor.where(member_id: self.id, group_id: group_id).first_or_initialize do |group_surveyor|
      group_surveyor.member_id = self.id
      group_surveyor.group_id = group_id
      group_surveyor.save!
    end
  end

  def remove_group_surveyor(group_id)
    find_group_surveyor = GroupSurveyor.find_by(member_id: self.id, group_id: group_id)
    find_group_surveyor.destroy if find_group_surveyor.present?
  end


  def new_avatar
    avatar.url(:thumbnail)
  end


  def get_activity_count
    find_activify = Activity.find_by(member_id: id)

    find_activify.present? ? find_activify.items.size : 0
  end

  def get_first_signup
    first_signup.present? ? true : false
  end

  def get_key_color
    key_color || ""
  end

  def Member.check_image_avatar(avatar)
    for_campare_url_image = /\.(gif|jpg|png)\z/i
    if for_campare_url_image.match(avatar.model[:avatar]).present?
      if avatar.model[:avatar].start_with?('http')
        avatar.model[:avatar]
      else
        avatar.url(:thumbnail)
      end
    else
      if avatar.present?
        avatar.model[:avatar] + ".jpg"
      else
        avatar.url(:thumbnail)
      end
    end
  end

  def recent_history_subscription
    @recent_subscription ||= HistoryPurchase.where("member_id = ? AND product_id IN (?)", id, ["1month", "1year"]).order("created_at desc")
  end

  def get_recent_history_subscription
    recent_history_subscription.present? ? recent_history_subscription.map(&:product_id).first : ""
  end

  def get_name
    fullname.presence || 'No name'
  end

  def get_username
    username.present? ? username : ""
  end

  def get_cover_image
    cover.present? ? cover.url(:cover) : ""
  end

  def get_cover_preset
    cover_preset.to_i
  end

  def remove_old_cover
    remove_cover!
    save!
  end

  def remove_old_avatar
    remove_avatar!
    save!
  end

  def set_friend_limit
    self.friend_limit = FRIEND_LIMIT
  end

  def is_admin_group(status)
    status ? "Admin" : "Member"
  end

  def get_recurring_available
    list_recurring = []
    recurrings.includes(:polls).each do |rec|
      unless rec.polls.present?
        list_recurring << rec
      end
    end
    list_recurring
  end

  # def get_stats_all
  #   {
  #     "my_poll" => cached_my_poll.size,
  #     "my_vote" => cached_my_voted.size,
  #     "my_watched" => cached_watched.size,
  #     "friend" => cached_get_friend_active.size,
  #     "group" => cached_get_group_active.size,
  #     "activity" => get_activity_count,
  #     "following" => cached_get_following.size,
  #     "direct_msg" => 0,
  #     "status" => 0
  #   }
  # end

  # def cached_poll_friend_count(member)
  #   Rails.cache.fetch([ self.id, 'friend_poll_count']) do
  #     FriendPollInProfile.new(member, self, {}).poll_friend_count
  #   end
  # end

  # def cached_voted_friend_count(member)
  #   Rails.cache.fetch([ self.id, 'friend_vote_count']) do
  #     FriendPollInProfile.new(member, self, {}).vote_friend_count
  #   end
  # end

  # def cached_groups_friend_count(member)
  #   FriendPollInProfile.new(member, self, {}).group_friend_count
  # end

  # def cached_watched_friend_count(member)
  #   Rails.cache.fetch([ self.id, 'friend_watch_count']) do
  #     FriendPollInProfile.new(member, self, {}).watched_friend_count
  #   end
  # end

  # def cached_block_friend_count(member)
  #   Rails.cache.fetch([ self.id, 'friend_block_count']) do
  #     FriendPollInProfile.new(member, self, {}).block_friend_count
  #   end
  # end


  # TODO : fixed or remove this cached IT fetch but never delete
  def cached_shared_poll
    Rails.cache.fetch("member/#{id}-#{updated_at.to_i}/shared") { share_polls.to_a }
  end

  def cached_report_poll
    Rails.cache.fetch("member/#{id}/report_polls") { poll_reports.to_a }
  end

  def cached_block_friend
    Rails.cache.fetch([self.id, 'block_friend']) do
      get_friend_blocked.to_a
    end
  end

  def my_vote_poll_ids
    Member.voted_polls.select{|e| e[:poll_series_id] == 0 }.collect{|e| e[:poll_id] }
  end

  # def cached_my_poll
  #   Rails.cache.fetch([self.id, 'my_poll']) do
  #     @init_poll = MyPollInProfile.new(self)
  #     @init_poll.my_poll.to_a
  #   end
  # end


  def cached_my_voted
    Rails.cache.fetch([self.id, 'my_voted']) do
      @init_poll = MyPollInProfile.new(self)
      @init_poll.my_vote.to_a
    end
  end

  def cached_my_voted_all
    Rails.cache.fetch([self.id, 'my_voted_all']) do
      Poll.joins(:history_votes => :choice)
        .select("polls.*, history_votes.choice_id as choice_id")
        .where("(history_votes.member_id = #{self.id} AND history_votes.poll_series_id = 0) " \
               "OR (history_votes.member_id = #{self.id} AND history_votes.poll_series_id != 0 AND polls.order_poll = 1)")
        .collect! { |poll| Hash["poll_id" => poll.id, "choice_id" => poll.choice_id, "poll_series_id" => poll.poll_series_id, "show_result" => poll.show_result, "system_poll" => poll.system_poll ] }.to_a
    end
  end

  def cached_watched
    Rails.cache.fetch([ self.id, 'watcheds' ]) do
      @init_poll = MyPollInProfile.new(self)
      @init_poll.my_watched.to_a
    end
  end

  def cached_get_unrecomment
    Rails.cache.fetch([self.id, 'unrecomment']) do
      member_un_recomments.to_a
    end
  end

  def cached_get_following
    Rails.cache.fetch([self.id, 'following']) do
      get_following.to_a
    end
  end

  def cached_get_follower
    Rails.cache.fetch([self.id, 'follower']) do
      get_follower.to_a
    end
  end

  def cached_get_friend_active
    Rails.cache.fetch([self.id, 'friend_active']) do
      get_friend_active.to_a
    end
  end

  def cached_get_your_request
    Rails.cache.fetch([self.id, 'your_request']) do
      get_your_request.to_a
    end
  end

  def cached_get_friend_request
    Rails.cache.fetch([self.id, 'friend_request']) do
      get_friend_request.to_a
    end
  end

  def cached_get_group_active
    Rails.cache.fetch([self.id, 'group_active']) do
      get_group_active.to_a
    end
  end

  def cached_get_my_rewards
    Rails.cache.fetch([self.id, 'reward']) do
      MemberReward.for_member_id(self.id).to_a
    end
  end

  def cached_ask_join_groups
    Rails.cache.fetch([self.id, 'ask_join_groups']) do
      ask_join_groups.to_a
    end
  end

  ## flush cache ##

  def flush_cache_about_poll
    flush_cache_my_poll
    flush_cache_my_vote
    FlushCached::Member.new(self).clear_list_voted_all_polls
    true
  end

  def flush_cache_my_poll
    Rails.cache.delete([self.id, 'my_poll'])
  end

  def flush_cache_my_vote
    Rails.cache.delete([self.id, 'my_voted'])
  end

  def flush_cache_my_vote_all
    Rails.cache.delete("member/#{id}/voted_all_polls")
  end

  def flush_cache_my_watch
    Rails.cache.delete([self.id, 'watcheds'])
  end

  def flush_cache_my_group
    Rails.cache.delete([self.id, 'group_active'])
  end

  def flush_cache_my_following
    Rails.cache.delete([self.id, 'following'])
  end

  def flush_cache_my_follower
    Rails.cache.delete([self.id, 'follower'])
  end

  def flush_cache_my_block
    Rails.cache.delete([self.id, 'block_friend'])
  end

  ## flush cache friend ##

  def flush_cache_friend_poll
    Rails.cache.delete([self.id, 'friend_poll_count'])
  end

  def flush_cache_friend_vote
    Rails.cache.delete([self.id, 'friend_vote_count'])
  end

  def flush_cache_friend_watch
    Rails.cache.delete([self.id, 'friend_watch_count'])
  end

  def flush_cache_ask_join_groups
    Rails.cache.delete([self.id, 'ask_join_groups'])
  end

  def campaigns_available
    campaign = campaigns.includes(:poll).order("name desc")
    campaign.delete_if{|x| x.poll.present? }
  end

  def list_voted?(poll)
    history_voted = Member::PollList.new(self).voted_all

    # history_voted = Member.voted_polls
    select_poll = history_voted.select { |his_vote| his_vote[:poll_id] == poll.id }.first

    if select_poll.present?
      choice_list ||= poll.cached_choices
      choice_voted = choice_list.select  {|e| e.id == select_poll[:choice_id] }.first.vote
      choice_answer = choice_list.select { |e| e.id == select_poll[:choice_id] }.first.answer
      return Hash["voted" => true, "choice_id" => select_poll[:choice_id], "answer" => choice_answer, "vote" => choice_voted]
    else
      return Hash["voted" => false]
    end
  end

  def list_voted_questionnaire?(poll_series)
    history_voted = Member.voted_polls

    history_voted.each do |poll|
      if poll[:poll_series_id] == poll_series.id
        return Hash["voted" => true]
      end
    end
    Hash["voted" => false]
  end

  def list_viewed?(poll_id)
    history_viewed = Member.viewed_polls
    history_viewed.include?(poll_id)
  end

  def viewed?(poll_id)
    find_viewed = history_views.where(poll_id: poll_id).first
    find_viewed.present?
  end

  def check_gender
    if gender.present? && gender != 0
      gender
    else
      "undefined"
    end
  end

  def self.update_profile(response)
    fullname = response["name"]
    sentai_fullname = response["fullname"]
    username = response["username"]
    email = response["email"]
    avatar = response["avatar_thumbnail"]
    birthday = response["birthday"]
    gender = response["gender"]

    find_member = where(email: email).first
    if find_member.present?
      find_member.update_attributes!(fullname: sentai_fullname, avatar: avatar, birthday: birthday, username: username, gender: gender)
      return find_member
    end
  end

  def self.check_subscribe
    list_member_subscribe_expiration = Member.where("date(subscribe_expire + interval '7 hour') = ?", Time.zone.today)

    list_member_subscribe_expiration_member_ids = list_member_subscribe_expiration.map(&:id).uniq

    list_member_subscribe_expiration.each do |member|
      Member::MemberList.new(member).followers.each do |follower|
         FlushCached::Member.new(follower).clear_list_friends
      end
      member.update!(subscription: false, subscribe_expire: nil, member_type: :citizen)
    end
    NotifyExpireSubscriptionWorker.perform_async(0, list_member_subscribe_expiration_member_ids) if list_member_subscribe_expiration_member_ids.size > 0
  end

  def self.notify_nearly_expire_subscription
    list_member_nearly_subscribe_expire = Member.where("date(subscribe_expire + interval '7 hour') = ?", Time.zone.today + 3.days).map(&:id).uniq
    NearlyExpireSubscriptionWorker.perform_async(0, list_member_nearly_subscribe_expire) if list_member_nearly_subscribe_expire.size > 0
  end

  def self.check_blacklist_members
    three_day_ago_blacklist_members = Member.where("date(blacklist_last_at + interval '7 hour') = ?", Time.zone.today - 3.days).uniq

    three_day_ago_blacklist_members.each do |member|
      member.update(status_account: :normal)
    end

    true
  end

  ########### Search Member #############

  def self.search_member(params)
    # if params[:q].present?
    #   searchable_member(params[:q])
    # end
    if params[:q].present?
      Member.with_status_account(:normal).where("fullname LIKE ? OR email LIKE ? OR public_id LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%")
    end
  end

  ################ Friend ###############


  def delete_group(group_id)
    find_group_member = group_members.where(group_id: group_id).first
    if find_group_member

      find_group_member.group.members.each do |member|
        FlushCached::Member.new(member).clear_list_groups
      end

      find_group_member.group.destroy if find_group_member.is_master
    end
    # cached_flush_active_group
  end

  def cached_flush_active_group
    Rails.cache.delete("/member/#{id}/groups")
    Rails.cache.delete([id, 'group_active'])
  end

  def check_share_poll?(poll_id)
    share_poll_ids = share_polls.pluck(:poll_id)
    if share_poll_ids.include?(poll_id)
      Hash["shared" => true]
      else
      Hash["shared" => false]
    end
  end

  def get_province
    province.present? ? province.value : ""
  end

  def get_birthday
    birthday.present? ? birthday.strftime("%b %d, %Y") : ""
  end

  def get_gender
    gender.present? ? gender.value : ""
  end

  def get_interests
    interests.present? ? interests.collect{|e| e.value } : ""
  end

  def get_salary
    salary.present? ? salary.value : ""
  end

  def get_fb_id
    fb_id.presence || ""
  end

  def get_token(provider_name)
    if provider_name.present?
      find_provider = providers.find_by(name: provider_name)
      find_provider.present? ? find_provider.token : ""
    else
      find_provider = providers.first
      find_provider.present? ? find_provider.token : ""
    end
  end

  def get_email
    email.present? ? email : ""
  end

  def get_template
    Template.where(member_id: id).first
  end

  def get_anonymous_with_poll(poll)
    if poll.in_group_ids != '0'
      anonymous_group
    else
      if poll.public
        anonymous_public
      else
        anonymous_friend_following
      end
    end
  end

  def get_roles
    roles.map(&:name).uniq
  end

  # def self.cached_member_of_poll(current_member, member_of_poll)
  #   MemberSerializer.new(member_of_poll, serializer_options: { current_member: current_member }).as_json
  # end

  def self.serializer_member_detail(current_member, member_of_poll)
    member_as_json = serializer_member_hash( cached_member(member_of_poll))
    member_hash = member_as_json.merge({ "status" => entity_info(current_member, member_of_poll)})
    member_hash
  end

  def self.entity_info(current_member, member_of_poll)
    member_of_poll.is_friend(current_member)
  end

  def self.cached_member(member)
    Rails.cache.fetch(member) do
      MemberInfoFeedSerializer.new(member).as_json()
    end
  end

  def self.serializer_member_hash(member)
    V5::MemberSerializer.new(member).as_json()
  end

  def self.cached_friend_entity(user, friend)
    Rails.cache.fetch(['user', user.id, 'friend_entity_with', friend.id]) do
      FriendSerializer.new(friend, serializer_options: { user: user} ).as_json
    end
  end

  def self.friend_entity(user, friend)
    FriendSerializer.new(friend, serializer_options: { user: user } ).as_json
  end

  def check_friend_entity(user)
    find_friend = Friend.where("(follower_id = ? AND followed_id = ? AND status = ?) " \
                        "OR (follower_id = ? AND followed_id = ? AND status = ?)",
                        user.id, id, 1,
                        user.id, id, -1).first

    if find_friend.present?
      {
        close_friend: find_friend.close_friend,
        block_friend: find_friend.block
      }
    else
      {
        close_friend: "",
        block_friend: ""
      }
    end
  end

  def as_json options={}
   {
      member_id: id,
      type: member_type_text,
      name: get_name,
      public_id: get_public_id,
      email: get_email,
      avatar: avatar.present? ? resize_avatar(avatar.url) : "",
      cover: cover.present? ? resize_cover(cover.url) : "",
      description: get_description,
      key_color: get_key_color
   }
  end

  def resize_avatar(avatar_url)
    avatar_url.split("upload").insert(1, "upload/c_fit,h_180,w_180," + Cloudinary::QualityImage::SIZE).sum
  end

  def resize_cover(cover_url)
    cover_url.split("upload").insert(1, "upload/c_fit,w_640," + Cloudinary::QualityImage::SIZE).sum
  end

  def is_friend(user_obj)
    init_list_friend ||= Member::MemberList.new(user_obj)

    @my_friend ||= init_list_friend.active.map(&:id)
    @your_request ||= init_list_friend.your_request.map(&:id)
    @friend_request ||= init_list_friend.friend_request.map(&:id)
    @my_following ||= init_list_friend.followings.map(&:id)
    @block_friend ||= init_list_friend.blocks.map(&:id)

    if @my_friend.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :friend]
    elsif @your_request.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :invite]
    elsif @friend_request.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :invitee]
    elsif @block_friend.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :block]
    else
      hash = Hash["add_friend_already" => false, "status" => :nofriend]
    end

    if celebrity? || brand?
      @my_following.include?(id) ? hash.merge!({"following" => true }) : hash.merge!({"following" => false })
    else
      hash.merge!({"following" => "" })
    end
    hash
  end

  def get_key_color
    key_color.present? ? key_color : ""
  end

  def get_description
    description.present? ? description : ""
  end

  def get_avatar
    if avatar.present?
      avatar.url(:thumbnail)
    else
      ""
    end
  end

  def self.update_avatar(current_member, file_avatar)
    member = current_member
    current_avatar = member.avatar.identifier
    if current_avatar.present?
      begin
        if current_avatar.start_with?('https://') || current_avatar.start_with?('http://')
          member.remove_avatar!
          member.save!
        end
      end
    end
    @member = Member.find(current_member.id)
    @member.update(avatar: file_avatar)
  end

  # def self.remove_cover(current_member)
    
  # end

  def serializer_member_detail  # for api
    @find_member_cached ||= Member.cached_find(self.id)

    @member_id = @find_member_cached.id
    serailizer_member_feed_info = MemberInfoFeedSerializer.new(@find_member_cached).as_json()

    serailizer_member_feed_info = serailizer_member_feed_info.merge( { "status" => entity_info } )
  end

  def entity_info
    @my_friend = Member.list_friend_active.map(&:id)
    @your_request = Member.list_your_request.map(&:id)
    @friend_request = Member.list_friend_request.map(&:id)
    @my_following = Member.list_friend_following.map(&:id)

    if @my_friend.include?(@member_id)
      hash = Hash["add_friend_already" => true, "status" => :friend]
    elsif @your_request.include?(@member_id)
      hash = Hash["add_friend_already" => true, "status" => :invite]
    elsif @friend_request.include?(@member_id)
      hash = Hash["add_friend_already" => true, "status" => :invitee]
    else
      hash = Hash["add_friend_already" => false, "status" => :nofriend]
    end

    if @find_member_cached.celebrity? || @find_member_cached.company?
      @my_following.include?(@member_id) ? hash.merge!({"following" => true }) : hash.merge!({"following" => false })
    else
      hash.merge!({"following" => "" })
    end
    hash
  end


  def detect_image(avatar)
    new_avatar = ""
    if avatar.present?
      if avatar.identifier.start_with?('http://')
        new_avatar = avatar.identifier
      elsif avatar.identifier.start_with?('https://') #facebook
        new_avatar = avatar.identifier
      else
        new_avatar = avatar.url(:thumbnail)
      end
    end
    new_avatar
  end

  def get_history_viewed
    @history_viewed = history_views.collect { |viewed| viewed.poll_id }
  end

  def get_request_code
    request_codes.first.present?
  end

  def post_poll_in_group(in_group_ids)
    init_list_group = Member::GroupList.new(self)

    get_list_group_ids = init_list_group.active.map(&:id)
    split_group_ids = in_group_ids.split(",").collect{|e| e.to_i }

    return split_group_ids & get_list_group_ids
  end

  def get_recent_activity
    # activity = Activity.find_by(member_id: id)

    # if activity.present?
    #   activity.items.select{|e| e["type"] == "Poll" && e["authority"] == "Public" && e["action"] != "Share" }[0..2]
    # else
    #   []
    # end

    Member::PollList.new(self).recent_public_activity(3).map do |poll| 
      {
        poll: {
          id: poll.id,
          title: poll.title,
          created_at: poll.created_at.to_i,
          public: poll.public,
          series: poll.series
        },
        creator: {
          member_id: poll.member_id,
          name: poll.member.fullname,
          avatar: poll.member.get_avatar
        },
        authority: 'Public',
        action: poll.action,
        type: 'Poll',
        activity_at: poll.activity_at.to_i
      }
    end
  end

  # def get_history_voted
  #   @history_voted = HistoryVote.joins(:member, :choice, :poll)
  #                               .select("history_votes.*, choices.answer as choice_answer, choices.vote as choice_vote")
  #                               .where("history_votes.member_id = #{id}")
  #                               .collect! { |voted| [voted.poll_id, voted.choice_id, voted.choice_answer, voted.poll_series_id, voted.choice_vote] }
  # end

end
