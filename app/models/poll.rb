# == Schema Information
#
# Table name: polls
#
#  id                      :integer          not null, primary key
#  member_id               :integer
#  title                   :text
#  public                  :boolean          default(FALSE)
#  vote_all                :integer          default(0)
#  created_at              :datetime
#  updated_at              :datetime
#  photo_poll              :string(255)
#  expire_date             :datetime
#  view_all                :integer          default(0)
#  start_date              :datetime         default(2014-02-03 15:36:16 UTC)
#  series                  :boolean          default(FALSE)
#  poll_series_id          :integer
#  choice_count            :integer
#  campaign_id             :integer
#  share_count             :integer          default(0)
#  recurring_id            :integer          default(0)
#  in_group_ids            :string(255)
#  qrcode_key              :string(255)
#  type_poll               :integer
#  report_count            :integer          default(0)
#  status_poll             :integer          default(0)
#  allow_comment           :boolean          default(TRUE)
#  comment_count           :integer          default(0)
#  member_type             :string(255)
#  qr_only                 :boolean
#  require_info            :boolean
#  expire_status           :boolean          default(FALSE)
#  creator_must_vote       :boolean          default(TRUE)
#  in_group                :boolean          default(FALSE)
#  show_result             :boolean          default(TRUE)
#  order_poll              :integer          default(1)
#  quiz                    :boolean          default(FALSE)
#  notify_state            :integer          default(0)
#  notify_state_at         :datetime
#  priority                :integer
#  thumbnail_type          :integer          default(0)
#  comment_notify_state    :integer          default(0)
#  comment_notify_state_at :datetime
#  draft                   :boolean          default(FALSE)
#  system_poll             :boolean          default(FALSE)
#  deleted_at              :datetime
#  close_status            :boolean          default(FALSE)
#

class Poll < ActiveRecord::Base
  # extend FriendlyId
  # friendly_id :slug_candidates, use: [:slugged, :finders]
  acts_as_paranoid

  mount_uploader :photo_poll, PhotoPollUploader

  include PgSearch
  include PollsHelper

  attr_accessor :group_id, :tag_tokens, :share_poll_of_id, :choice_one, :choice_two, :choice_three, :remove_campaign

  cattr_accessor :custom_error_message

  pg_search_scope :search_with_tag, against: [:title],
    using: { tsearch: {dictionary: "english", prefix: true} },
    associated_against: {tags: [:name] }

  pg_search_scope :search_with_choice, against: [:title],
    using: { tsearch: {dictionary: "english", prefix: true, :any_word => true }, :trigram => { :threshold => 0.1 } },
    associated_against: { choices: [:answer] }

  has_many :choices

  has_many :poll_attachments, -> { order('order_image asc') }

  has_many :taggings

  has_many :tags, through: :taggings, source: :tag

  has_many :watcheds
  has_many :watched_by_member, through: :watcheds, source: :member

  has_many :poll_groups, -> { where("poll_groups.deleted_at IS NULL") }, dependent: :destroy
  has_many :groups, through: :poll_groups, source: :group

  has_many :poll_members
  has_many :members, through: :poll_members, source: :member

  has_many :campaign_members

  has_many :comments

  has_many :history_votes

  has_many :who_voted,  through: :history_votes, source: :member

  has_many :history_views
  has_many :share_polls
  has_many :hidden_polls

  has_many :member_report_polls

  has_many :un_see_polls, as: :unseeable
  has_many :save_poll_laters, as: :savable

  has_many :bookmarks, as: :bookmarkable

  has_many :branch_polls
  has_many :branches, through: :branch_polls, source: :branch

  has_one :history_promote_poll, dependent: :destroy

  has_many :triggers, as: :triggerable
  has_many :member_report_comments

  has_one :poll_company

  belongs_to :member, counter_cache: true
  belongs_to :poll_series
  belongs_to :campaign
  belongs_to :recurring

  before_save :set_default_value
  after_create :set_priority

  validates_presence_of :title, :on => :create
  validates_presence_of :member_id, :on => :create

  validates_numericality_of :view_all, :greater_than_or_equal_to => 0
  validates_numericality_of :vote_all, :greater_than_or_equal_to => 0

  delegate :creator_name, :to => :'member.fullname'

  after_commit :send_notification, on: :create
  after_commit :flush_cache
  after_commit :flush_cache_choice

  accepts_nested_attributes_for :choices, :reject_if => lambda { |a| a[:answer].blank? }, :allow_destroy => true

  accepts_nested_attributes_for :poll_attachments, :reject_if => lambda { |a| a[:image].blank? }, :allow_destroy => true

  default_scope { with_deleted.order("#{table_name}.created_at desc") }

  scope :public_poll, -> { where(public: true) }
  scope :active_poll, -> { where("expire_date > ?", Time.zone.now) }
  scope :inactive_poll, -> { where("expire_date < ?", Time.zone.now) }

  scope :load_more, -> (next_poll) { next_poll.present? ? where("polls.id < ?", next_poll) : nil }

  scope :without_my_poll, -> (member_id) { where("polls.member_id != ?", member_id) }

  scope :available, -> {
    member_report_poll = Member.reported_polls.map(&:id)  ## poll ids
    member_block_and_banned = Member.list_friend_block.map(&:id) | Admin::BanMember.cached_member_ids

    query = having_status_poll(:gray, :white).where(draft: false, deleted_at: nil)
    query = query.where("#{table_name}.id NOT IN (?)", member_report_poll) if member_report_poll.size > 0
    query = query.where("#{table_name}.member_id NOT IN (?)", member_block_and_banned) if member_block_and_banned.size > 0
    query
  }

  scope :without_deleted, -> { where(deleted_at: nil) }

  scope :have_vote, -> { where("polls.vote_all > 0") }
  scope :unexpire, -> {
    where("polls.expire_status = 'f'")
  }

  scope :except_series, -> { where(series: false) }
  scope :except_qrcode, -> { where(qr_only: false) }

  scope :without_closed, -> { where(close_status: false) }

  LIMIT_POLL = 30
  LIMIT_TIMELINE = 500

  self.per_page = 20

  amoeba do
    enable
    set [{:vote_all => 0}, {:view_all => 0}, {:share_count => 0} ]

    customize(lambda { |original_poll, new_poll|
                new_poll.expire_date = original_poll.expire_date + 1.day
                new_poll.created_at = Time.now
    })

    include_association [:choices]
  end

  rails_admin do
    list do
      filters [:member, :title]
      field :id

      field :member do
        searchable :fullname
        pretty_value do
          %{<a href="/admin/member/#{value.id}">#{value.fullname}</a>}.html_safe
        end
      end

      field :title
      field :public
      field :photo_poll
      field :vote_all
      field :view_all
      field :created_at do
        pretty_value do
          ActionController::Base.helpers.time_ago_in_words(bindings[:object].created_at) + ' ago'
        end
      end

    end

    edit do
      field :title
      field :vote_all
      field :view_all
      field :comment_count
      field :public
      field :status_poll
      field :allow_comment
      field :expire_status
      field :creator_must_vote
      field :priority
      field :draft
      field :system_poll
      field :deleted_at
      field :close_status
      field :created_at
    end
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) do
      @poll = find_by(id: id)
      raise ExceptionHandler::NotFound, ExceptionHandler::Message::Poll::NOT_FOUND unless @poll.present?
      raise ExceptionHandler::Deleted, ExceptionHandler::Message::Poll::DELETED unless @poll.deleted_at.nil?
      @poll
    end
  end

  def self.raw_cached_find(id)
    Rails.cache.fetch([name, id]) do
      find_by(id: id)
    end
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def flush_cache_choice
    Rails.cache.delete("poll/#{id}/choices")
  end

  def cached_choices
    Rails.cache.fetch("poll/#{id}/choices") { choices.to_a }
  end

  def cached_poll_attachements
    Rails.cache.fetch("poll/#{id}/poll_attachments") do
      poll_attachments.to_a
    end
  end

  def send_notification
    unless Rails.env.test?
      if in_group
        in_group_ids.split(",").each do |group_id|
          unless qr_only
            AddPollToGroupWorker.perform_async(self.member_id, group_id.to_i, self.id)
          end
        end
      else
        unless qr_only || series
          if public
            PollPublicWorker.perform_async(member_id, id)
          else
            PollWorker.perform_async(self.member_id, self.id)
          end
        end
      end
    end
  end

  def get_original_images
    if cached_poll_attachements.size > 0
      cached_poll_attachements.collect{|attachment| attachment.image.url(:original) }
    else
      if have_photo?
        photo_poll.url(:original).split(",")
      end
    end
  end

  def set_priority
    if public
      update(priority: 0)
    else
      if in_group
        update(priority: 0)
      else
        update(priority: 0)
      end
    end
  end

  def voted?(member)
    Member::ListPoll.new(member).voted_poll?(self)
  end

  def generate_qrcode_key
    begin
      self.qrcode_key = SecureRandom.hex(6)
    end while self.class.exists?(qrcode_key: qrcode_key)
    qrcode_key
  end

  def get_creator_must_vote
    creator_must_vote.present? ? true : false
  end

  def get_vote_max
    @choice ||= cached_choices
    @choice.sort {|x,y| y["vote"] <=> x["vote"] }[0..1].collect{|c| Hash["choice_id" => c.id, "answer" => c.answer, "vote" => c.vote] }.compact
  end

  def get_vote_max_no_cached
    choices.sort {|x,y| y["vote"] <=> x["vote"] }[0..1].collect{|c| Hash["choice_id" => c.id, "answer" => c.answer, "vote" => c.vote] }.compact
  end

  def get_vote_max_non_cache
    @choice ||= choices.to_a
    @choice.sort {|x,y| y["vote"] <=> x["vote"] }[0..1].collect{|c| Hash["choice_id" => c.id, "answer" => c.answer, "vote" => c.vote] }.compact
  end

  def get_choice_detail
    ActiveModel::ArraySerializer.new(cached_choices, each_serializer: ChoiceSerializer).as_json
  end

  def self.close_all_poll_that_expired
    poll_expired = Poll.where("date(expire_date + interval '7 hour') = ?", Time.zone.now)
    poll_expired.collect {|poll| poll.update!(close_status: true, expire_status: true) }
  end

  def get_in_groups(groups_by_name)
    group = []
    split_group_id ||= in_group_ids.split(",").map(&:to_i)
    split_group_id.each do |id|
      if groups_by_name.has_key?(id)
        group << groups_by_name.fetch(id)
      end
    end

    if group.empty?
      if @group_id.present?
        group << GroupDetailSerializer.new(Group.find(@group_id)).as_json
      else
        find_group = Group.where("id IN (?)", split_group_id).first
        group << GroupDetailSerializer.new(find_group).as_json
      end
    end

    group
  end

  def get_within(options = {}, action_timeline = {}, group_id = nil)
    @group_id = group_id
    if public && in_group
      Hash["in" => "Group", "group_detail" => get_in_groups(options)]
    elsif public
      if action_timeline["friend_following_poll"]
        PollType.to_hash(PollType::WHERE[:friend_following])
      else
        PollType.to_hash(PollType::WHERE[:public])
      end
    else
      if in_group
        Hash["in" => "Group", "group_detail" => get_in_groups(options)]
      else
        PollType.to_hash(PollType::WHERE[:friend_following])
      end
    end
  end

  def poll_is_where
    if public
      PollType.to_hash(PollType::WHERE[:public])
    else
      if in_group != true
        PollType.to_hash(PollType::WHERE[:friend_following])
      else
        PollType.to_hash(PollType::WHERE[:group])
      end
    end
  end

  def set_default_value
    self.recurring_id = 0 unless self.recurring_id.present?
    self.campaign_id = 0 unless self.campaign_id.present?
  end

  def cached_tags
    Rails.cache.fetch("/poll/#{id}/tags") do
      tags.pluck(:name)
    end
  end

  def cached_member
    Rails.cache.fetch(['member', self.member.updated_at.to_i]) do
      member.as_json()
    end
  end

  def get_campaign
    (campaign_id != 0) ? true : false
  end

  def get_list_reward
    reward_info ||= campaign.rewards.first
    @reward_info = {}

    if reward_info
      @reward_info = [{
        title: reward_info.title,
        detail: reward_info.detail,
        expire: reward_info.reward_expire.to_i,
        redeem_myself: campaign.redeem_myself
      }]
    end

    @reward_info
  end

  def get_reward_info(member, campaign)
    campaign.campaign_members.find_by(poll: self, member: member).presence || {}
  end

  def get_campaign_detail(member)
    campaign.as_json.merge(list_reward: get_list_reward).merge(reward_info: get_reward_info(member, campaign))
  end

  def get_photo
    photo_poll.url(:medium).presence || ""
  end

  def closed?
    close_status
  end

  def tag_tokens=(tokens)
    self.tag_ids = Tag.ids_from_tokens(tokens)
  end

  def self.tag_counts
    Tag.joins(:taggings).select("tags.*, count(tag_id) as count").group("tags.id")
  end

  def create_watched(member, poll_id)
    WatchPoll.new(member, poll_id).watching
  end

  def self.get_choice_count(choices)
    choices.size
  end

  def create_tag(title)
    split_tags = []
    title.gsub(/\B#([[:word:]]+)/) { split_tags << $1 }
    if split_tags.size > 0
      tag_list = []
      split_tags.each do |tag_name|
        tag_list << Tag.find_or_create_by(name: tag_name).id
      end
      self.tag_ids = tag_list
    end
  end

  def self.vote_poll(poll, member, data_options = {})
    member_id = poll[:member_id]
    surveyor_id = poll[:surveyor_id]
    poll_id = poll[:id]
    choice_id = poll[:choice_id]
    guest_id = poll[:guest_id]
    show_result = poll[:show_result]

    find_poll = Poll.find_by(id: poll_id)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::NOT_FOUND if find_poll.nil?
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::UNDER_INSPECTION if find_poll.black?
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::CLOSED if find_poll.closed?
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::EXPIRED if find_poll.expire_date < Time.zone.now

    ever_vote = Member::ListPoll.new(member).voted_poll?(find_poll)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::VOTED if ever_vote

    find_choice = Choice.find_by(id: choice_id)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Choice::NOT_FOUND if find_choice.nil?

    poll_series_id = find_poll.series ? find_poll.poll_series_id : 0

    find_poll.with_lock do
      find_poll.vote_all += 1
      find_poll.save!
    end

    find_choice.with_lock do
      find_choice.vote += 1
      find_choice.save!
    end

    Company::TrackActivityFeedPoll.new(member, find_poll.in_group_ids, find_poll, "vote").tracking if find_poll.in_group

    UnseePoll.new({member_id: member_id, poll_id: poll_id}).delete_unsee_poll

    SavePollLater.delete_save_later(member_id, find_poll)

    unless show_result.nil?
      check_show_result = show_result
    else
      check_show_result = show_result?(member, find_poll)
    end

    if (member.id != find_poll.member_id) && !find_poll.series
      if find_poll.notify_state.idle?
        find_poll.update_column(:notify_state, 1)
        find_poll.update_column(:notify_state_at, Time.zone.now)
        SumVotePollWorker.perform_in(1.minutes, poll_id, show_result) unless Rails.env.test?
      end

      Poll::VoteNotifyLog.new(member, find_poll, check_show_result).create!
    end

    history_voted = member.history_votes.create!(poll_id: poll_id, choice_id: choice_id, poll_series_id: poll_series_id, data_analysis: data_options, surveyor_id: surveyor_id, created_at: Time.zone.now + 0.5.seconds, show_result: check_show_result)

    unless find_poll.series
      VoteStats.create_vote_stats(find_poll)
      Activity.create_activity_poll(member, find_poll, 'Vote')
    end
    Trigger::Vote.new(member, find_poll, find_choice).trigger!

    member.flush_cache_my_vote
    FlushCached::Member.new(member).clear_list_voted_all_polls

    find_poll.touch
    find_choice.touch
    [find_poll, history_voted]
  end

  def self.show_result?(member, find_poll)
    show_result = false

    show_result = if find_poll.public
      !member.anonymous_public
    else
      if find_poll.in_group
        !member.anonymous_group
      else
        !member.anonymous_friend_following
      end
    end

    show_result
  end

  def self.get_poll_hourly
    hour = Time.zone.now.hour
    start_time = Time.new(2000, 01, 01, hour, 00, 00)
    end_time = start_time.change(min: 59, sec: 59)
    @recurring = Recurring.where("(period BETWEEN ? AND ?) AND end_recur > ?", start_time.to_s, end_time.to_s, Time.zone.now).having_status(:active)
    if @recurring.size > 0
      Recurring.re_create_poll(@recurring)
    end
  end

  def have_photo?
    photo_poll.present?
  end

  def check_recurring
    if recurring_id != 0
      recurring.description
    else
      "-"
    end
  end

  def check_my_shared(my_shared_ids, poll_id)
    if my_shared_ids.include?(poll_id)
      Hash["shared" => true]
    else
      Hash["shared" => false]
    end
  end

  def check_watched
    watched_poll_ids = Member.watched_polls
    if watched_poll_ids.include?(id)
      true
    else
      false
    end
  end

  def get_require_info
    require_info.present? ? true : false
  end

  def hour
    self.created_at.utc.strftime('%Y-%m-%d %H:00:00 UTC')
  end

  def as_json options={}
    {
      id: id,
      text: title
    }
  end

  def check_status_survey(member)

    @init_member_suveyable = Surveyor::MembersSurveyable.new(self, member)

    @members_surveyable = @init_member_suveyable.get_members_in_group.to_a.map(&:id)

    @members_voted = @init_member_suveyable.get_members_voted.to_a.map(&:id)

    remain_can_survey = @members_surveyable - @members_voted

    complete_status = remain_can_survey.size > 0 ? false : true

    {
      complete: complete_status,
      member_voted: @members_voted.to_a.size,
      member_amount: @members_surveyable.size
    }
  end

  def find_campaign_for_predict?(member)
    campaign.prediction(member.id, self.id) if (campaign.expire > Time.now) && (campaign.used < campaign.limit) && (campaign.campaign_members.find_by(member_id: member.id, poll_id: self.id).nil?)
  end

  def self.view_poll(poll, member)
    HistoryView.transaction do
      begin
        @poll = poll.reload
        @member = member

        unless HistoryView.exists?(member_id: @member.id, poll_id: @poll.id)
          HistoryView.create! member_id: @member.id, poll_id: @poll.id
          Company::TrackActivityFeedPoll.new(@member, @poll.in_group_ids, @poll, "view").tracking if @poll.in_group

          @poll.with_lock do
            @poll.view_all += 1
            @poll.save!
          end

          FlushCached::Member.new(@member).clear_list_history_viewed_polls
        end
      rescue => e
        puts "message => #{e.message}"
      end
    end
  end

  ## for group api ##

  def get_member_shared_this_poll(group_id)
    member = Member.joins(:share_polls).where("share_polls.poll_id = ? AND share_polls.shared_group_id = ?", id, group_id)
    ActiveModel::ArraySerializer.new(member, serializer_options: { current_member: Member.current_member }, each_serializer: MemberSharedDetailSerializer).as_json()
  end

  def get_group_shared(group_id)
    @group_id = group_id
    @poll_id = id
    Hash["in" => "Group", "group_detail" => serailize_group_detail_as_json ]
  end

  def serailize_group_detail_as_json
    group = PollGroup.where(poll_id: @poll_id).pluck(:group_id)
    your_group_ids = Member.list_group_active.map(&:id)
    group_list = group & your_group_ids

    if group.present?
      ActiveModel::ArraySerializer.new(Group.where("id IN (?)", group_list), each_serializer: GroupSerializer).as_json()
    else
      nil
    end
  end

  def serializer_member_detail
    @find_member_cached ||= Member.cached_member(member)
    @member_id = @find_member_cached[:member_id]
    @member_type = @find_member_cached[:type]
    member_hash = @find_member_cached.merge( { "status" => entity_info } )
    member_hash
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

    if @member_type == "Citizen" || @member_type == "Brand"
      @my_following.include?(@member_id) ? hash.merge!({"following" => true }) : hash.merge!({"following" => false })
    else
      hash.merge!({"following" => "" })
    end
    hash
  end

  #### deprecated ####

  # def get_poll_in_groups(group_ids)
  #   groups.includes(:groups).where("poll_groups.group_id IN (?)", group_ids)
  # end

  # def set_new_title_with_tag
  #   poll_title = self.title
  #   tags.pluck(:name).each do |tag|
  #     poll_title = poll_title + " " + "#" + tag
  #   end
  #   update_attributes!(title: poll_title)
  # end

  #### deprecated ####

  # def self.get_public_poll(member, option = {})
  #   list_friend = member.whitish_friend.map(&:followed_id) << member.id
  #   query_poll = Poll.includes(:member, :choices).where("member_id IN (?) OR public = ?", list_friend, true)

  #   if option[:next_poll]
  #     if option[:type] == "active"
  #       query_poll.active_poll.load_more(option[:next_poll])
  #     elsif option[:type] == "inactive"
  #       query_poll.inactive_poll.load_more(option[:next_poll])
  #     else
  #       query_poll.load_more(option[:next_poll])
  #     end
  #   else
  #     if option[:type] == "active"
  #       query_poll.active_poll
  #     elsif option[:type] == "inactive"
  #       query_poll.inactive_poll
  #     else
  #       query_poll
  #     end
  #   end
  # end

  #### deprecated ####

  # def self.get_my_vote_my_poll(member_obj, status, options = {})
  #   next_cursor = options[:next_cursor]
  #   type = options[:type]
  #   if status == ENV["MY_POLL"]
  #     query_poll = member_obj.get_my_poll
  #   end

  #   @poll = filter_type(query_poll, type)

  #   if next_cursor.presence && status == ENV["MY_POLL"]
  #     @poll = @poll.load_more(next_cursor)
  #   end

  #   if @poll.size == LIMIT_POLL
  #     if status == ENV["MY_POLL"]
  #       next_cursor = @poll.to_a.last.id
  #     end
  #   else
  #     next_cursor = 0
  #   end

  #   [@poll, next_cursor]
  # end

  #### deprecated ####

  # def self.cached_find_poll(member_obj, status)
  #   puts "status => #{status}"

  #   Rails.cache.fetch([ status, member_obj.id, @type ]) do
  #     if status == ENV["PUBLIC_POLL"]
  #       PollMember.timeline(member_obj.id, member_obj.whitish_friend.map(&:followed_id), @type)
  #     elsif status == ENV["FRIEND_FOLLOWING_POLL"]
  #       PollMember.friend_following_timeline(member_obj, member_obj.id, member_obj.whitish_friend.map(&:followed_id), @type)
  #     elsif status == ENV["MY_POLL"]
  #       PollMember.find_my_poll(member_obj.id, @type)
  #     else

  #     end
  #   end
  # end

  #### deprecated ####

  # def self.list_of_poll(member_obj, status, options = {})
  #   # puts "options =>  #{options}"
  #   next_cursor = options[:next_cursor]
  #   @type = options[:type]

  #   if next_cursor.presence && next_cursor != "0"
  #     next_cursor = next_cursor.to_i
  #     @cache_polls = cached_find_poll(member_obj, status)
  #     index = @cache_polls.index(next_cursor)
  #     index = -1 if index.nil?
  #     poll = @cache_polls[(index+1)..(LIMIT_POLL+index)]
  #   else
  #     Rails.cache.delete([status, member_obj.id, @type])
  #     @cache_polls = cached_find_poll(member_obj, status)
  #     poll = @cache_polls[0..(LIMIT_POLL - 1)]
  #   end

  #   if @cache_polls.size > LIMIT_POLL
  #     if poll.size == LIMIT_POLL
  #       if @cache_polls[-1] == poll.last
  #         next_cursor = 0
  #       else
  #         next_cursor = poll.last
  #       end
  #     else
  #       next_cursor = 0
  #     end
  #   else
  #     next_cursor = 0
  #   end

  #   if status == ENV["PUBLIC_POLL"]
  #     filter_poll(poll, next_cursor)
  #   elsif status == ENV["FRIEND_FOLLOWING_POLL"]
  #     filter_poll(poll, next_cursor)
  #   elsif status == ENV["MY_POLL"]
  #     filter_my_poll_my_vote(poll, next_cursor)
  #   else

  #   end
  # end

  #### deprecated ####

  # def self.filter_poll(poll_ids, next_cursor)
  #   poll_series = []
  #   poll_nonseries = []
  #   series_shared = []
  #   nonseries_shared = []
  #   poll_member = PollMember.includes([{:poll => [:choices, :campaign, :poll_series, :member]}]).where("id IN (?)", poll_ids).order("id desc")

  #   poll_member.each do |poll_member|
  #     if poll_member.share_poll_of_id == 0
  #       not_shared = Hash["shared" => false]
  #       if poll_member.poll.series
  #         poll_series << poll_member.poll
  #         series_shared << not_shared
  #       else
  #         poll_nonseries << poll_member.poll
  #         nonseries_shared << not_shared
  #       end
  #     else
  #       find_poll = Poll.find_by(id: poll_member.share_poll_of_id)
  #       shared = Hash["shared" => true, "shared_by" => poll_member.member.as_json()]
  #       if find_poll.present?
  #         if find_poll.series
  #           poll_series << find_poll
  #           series_shared << shared
  #         else
  #           poll_nonseries << find_poll
  #           nonseries_shared << shared
  #         end
  #       end
  #     end
  #   end
  #   # puts "poll nonseries : #{poll_nonseries}"
  #   # puts "share nonseries: #{nonseries_shared}"
  #   [poll_series, series_shared, poll_nonseries, nonseries_shared, next_cursor]
  # end

  #### deprecated ####

  # def self.filter_my_poll_my_vote(poll_ids, next_cursor)
  #   poll_series = []
  #   poll_nonseries = []

  #   Poll.includes(:member).where("id IN (?)", poll_ids).order("id desc").each do |poll|
  #     if poll.series
  #       poll_series << poll
  #     else
  #       poll_nonseries << poll
  #     end
  #   end

  #   [poll_series, poll_nonseries, next_cursor]
  # end

  #### deprecated ####

  # def self.split_poll(list_of_poll)
  #   poll_series = []
  #   poll_nonseries = []

  #   list_of_poll.each do |poll|
  #     if poll.series
  #       poll_series << poll
  #     else
  #       poll_nonseries << poll
  #     end
  #   end

  #   [poll_series, poll_nonseries]
  # end

  #### deprecated ####

  # def find_poll_series(member_id, series_id)
  #   Poll.where(member_id: member_id, poll_series_id: series_id).order("id asc")
  # end

  #### deprecated ####

  # def self.get_group_poll(member, option = {})
  #   list_group = member.groups.map(&:id)
  #   if option[:next_poll]
  #     Poll.joins(:groups).where("groups.id IN (?)", list_group).includes(:member, :choices).where("id < ?", option[:next_poll])
  #   else
  #     Poll.joins(:groups).where("groups.id IN (?)", list_group).includes(:member, :choices)
  #   end
  # end

  #### deprecated ####

  # def self.create_poll(poll_params, member) ## create poll for API is deprecated...
  #   Poll.transaction do
  #     begin
  #       title = poll_params[:title]
  #       expire_date = poll_params[:expire_within]
  #       choices = poll_params[:choices]
  #       group_id = poll_params[:group_id]
  #       member_id = poll_params[:member_id]
  #       friend_id = poll_params[:friend_id]
  #       type_poll = poll_params[:type_poll]
  #       is_public = poll_params[:is_public].to_b
  #       photo_poll = poll_params[:photo_poll]
  #       original_images = poll_params[:original_images]
  #       allow_comment = poll_params[:allow_comment].present? ? true : false
  #       creator_must_vote = poll_params[:creator_must_vote].present? ? true : false
  #       require_info = poll_params[:require_info].present? ? true : false
  #       show_result = poll_params[:show_result].present? ? true : false
  #       qr_only = poll_params[:qr_only].present? ? true : false
  #       quiz = poll_params[:quiz].present? ? true : false
  #       thumbnail_type = poll_params[:thumbnail_type] || 0
  #       choices = check_type_of_choice(choices)
  #       choice_count = get_choice_count(choices)
  #       list_group_id = []
  #       in_group_ids = group_id
  #       in_group = group_id.present? ? true : false

  #       init_photo_poll = ImageUrl.new(photo_poll)

  #       if expire_date.present?
  #         convert_expire_date = Time.now + expire_date.to_i.day
  #       else
  #         convert_expire_date = Time.now + 100.years.to_i
  #       end

  #       raise ArgumentError, ExceptionHandler::Message::Poll::POINT_ZERO if (member.citizen? && is_public) && (member.point <= 0)

  #       if in_group
  #         list_group_id = in_group_ids.split(",").map(&:to_i)
  #         unless member.company?
  #           remain_group = member.post_poll_in_group(in_group_ids)
  #           if (remain_group.size > 0)
  #             if remain_group != list_group_id
  #               group_names = Group.where(id: (list_group_id - remain_group)).map(&:name).join(', ')
  #               alert_message = "This poll don't show in #{group_names} because you're no longer these group."
  #             end
  #             list_group_id = remain_group
  #           else
  #             group_names = Group.where(id: list_group_id).map(&:name).join(', ')
  #             alert_message = "You're no longer #{group_names}."
  #             raise ArgumentError, "You're no longer #{group_names}."
  #           end
  #         end
  #       end

  #       if group_id.present?
  #         @set_public = false
  #       else
  #         if (member.celebrity? || member.brand?)
  #           @set_public = true
  #           @set_public = false unless is_public
  #         else
  #           @set_public = is_public
  #         end
  #       end

  #       new_in_group_ids = list_group_id.join(",").presence || "0"

  #       @poll = Poll.new(member_id: member_id, title: title, expire_date: convert_expire_date, public: @set_public, poll_series_id: 0, series: false, choice_count: choice_count, in_group_ids: new_in_group_ids,
  #                       type_poll: type_poll, photo_poll: photo_poll, status_poll: 0, allow_comment: allow_comment, member_type: member.member_type_text, creator_must_vote: creator_must_vote, require_info: require_info, quiz: quiz, in_group: in_group, qr_only: qr_only, thumbnail_type: thumbnail_type)

  #       @poll.qrcode_key = @poll.generate_qrcode_key

  #       if @poll.valid? && choices
  #         @poll.save!
  #         PollCompany.create_poll(@poll, member.get_company, :mobile) if member.company?

  #         if photo_poll && init_photo_poll.from_image_url?
  #           @poll.update_column(:photo_poll, init_photo_poll.split_cloudinary_url)
  #         end

  #         @poll.add_attachment_image(original_images) if original_images.present?

  #         @choices = Choice.create_choices(@poll.id, choices)

  #         if @choices.present?
  #           @poll.create_tag(title)

  #           @poll.create_watched(member, @poll.id)

  #           if group_id
  #             Group.add_poll(member, @poll, list_group_id)
  #             @poll.poll_members.create!(member_id: member_id, share_poll_of_id: 0, public: @set_public, series: false, expire_date: convert_expire_date, in_group: true)
  #             Company::TrackActivityFeedPoll.new(member, @poll.in_group_ids, @poll, "create").tracking if @poll.in_group
  #           else
  #             @poll.poll_members.create!(member_id: member_id, share_poll_of_id: 0, public: @set_public, series: false, expire_date: convert_expire_date)
  #           end

  #           if member.citizen? && is_public
  #             if member.point > 0
  #               member.with_lock do
  #                 member.point -= 1
  #                 member.save!
  #               end
  #             end
  #           end

  #           MemberActiveRecord.record_member_active(member)

  #           PollStats.create_poll_stats(@poll)

  #           Activity.create_activity_poll(member, @poll, 'Create')

  #           @poll.flush_cache

  #           [@poll, nil, alert_message]
  #         end
  #       else
  #         [nil, @poll.errors.full_messages.join(", "), alert_message]
  #       end

  #     rescue ArgumentError => detail
  #       [@poll = nil, detail.message, alert_message]
  #     end

  #   end ## transaction
  # end

  #### deprecated ####

  # def add_attachment_image(original_images)
  #   init_original_images = ImageUrl.new(original_images.first)

  #   if init_original_images.from_image_url?
  #     new_original_images = original_images.collect!{|image_url| ImageUrl.new(image_url).split_cloudinary_url }

  #     new_original_images.each_with_index do |url_attachment, index|
  #       poll = poll_attachments.create!(image: url_attachment, order_image: index+1)
  #       poll.update_column(:image, url_attachment)
  #     end
  #   else
  #     original_images.each_with_index do |attachment, index|
  #       poll_attachments.create!(image: attachment, order_image: index+1)
  #     end
  #   end
  # end

  #### deprecated ####

  # def should_generate_new_friendly_id?
  #   title_changed? || super
  # end

  #### deprecated ####

  # def self.check_type_of_choice(choices)
  #   raise ExceptionHandler::UnprocessableEntity, "You must have choices attribuites." unless choices.present?
  #   unless choices.class == Array
  #     choices = choices.split(",")
  #   end
  #   choices
  # end

  #### deprecated ####

  # def self.new_hash_for_analysis(hash_analysis)
  #   if hash_analysis.present?
  #     new_hash = {}
  #     list_gender ||= Member.gender.values.collect{|e| [e.value, e.text]}
  #     list_salary ||= Member.salary.values.collect{|e| [e.value, e.text]}
  #     list_provice ||= Member.province.values.collect{|e| [e.value, e.text]}

  #     hash_analysis.each do |key, value|
  #       if key == "gender"
  #         compare = list_gender.select{|e| e.first == value.to_i }.first.last
  #         new_hash.merge!(key => compare)
  #       elsif key == "salary"
  #         compare = list_salary.select{|e| e.first == value.to_i }.first.last
  #         new_hash.merge!(key => compare)
  #       elsif key == "province"
  #         compare = list_provice.select{|e| e.first == value.to_i }.first.last
  #         new_hash.merge!(key => compare)
  #       elsif key == "birthday"
  #         new_hash.merge!(key => value)
  #       end
  #     end
  #     return new_hash
  #   end
  # end

  #### deprecated ####

  # def get_choice_scroll
  #   cached_choices.sort { |x,y| y.id <=> x.id }.map(&:vote)
  # end

  #### deprecated ####

  # def self.filter_type(query, type)
  #   case type
  #   when "active" then query.active_poll
  #   when "inactive" then query.inactive_poll
  #   else query
  #   end
  # end

  #### deprecated ####

  # def get_expire_date
  #   expire_date.present? ? expire_date.to_i : ""
  # end

  #### deprecated ####

  # def self.total_grouped_by_date(start)
  #   polls = where(created_at: start.beginning_of_day..Time.zone.now)
  #   polls = polls.select("date(created_at) as created_at, count(*) as total_poll")
  #   polls = polls.group("date(created_at)")

  #   polls.each_with_object({}) do |poll, hsh|
  #     hsh[poll.created_at.to_date] = poll.total_poll
  #   end

  # end

end
