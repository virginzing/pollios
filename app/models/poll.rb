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
  include PollAdmin


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

  has_many :member_report_polls

  has_many :not_interested_polls, as: :unseeable
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

  default_scope {  with_deleted.order("#{table_name}.created_at desc") }

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

  scope :viewing_by_member, (lambda do |viewing_member|
    without_banned_member
    .without_black_status
    .without_deleted
    .without_draft
    .without_not_interested(viewing_member)
    .without_incoming_block(viewing_member)
    .without_group_inivisibility(viewing_member)
    .except_qrcode
    # .wihtout_reported(viewing_member)
  end)

  scope :without_banned_member, (lambda do
    banned_member = Admin::BanMember.cached_member_ids
    where.not('polls.member_id IN (?)', banned_member) if banned_member.count > 0
  end)

  scope :without_black_status, -> { where.not('polls.status_poll = -1') }

  scope :without_draft, -> { where.not('polls.draft') }

  scope :without_group_inivisibility, (lambda do |viewing_member|
    group_active_ids = Member::GroupList.new(viewing_member).active_ids

    joins('LEFT OUTER JOIN poll_groups on polls.id = poll_groups.poll_id')
    .where('poll_groups.group_id IN (?) or polls.in_group = false', group_active_ids)
    .uniq
  end)

  scope :wihtout_reported, (lambda do |viewing_member|
    reported_poll_ids = Member::PollList.new(viewing_member).reports_ids
    where('polls.id NOT IN (?)', reported_poll_ids) if reported_poll_ids.count > 0
  end)

  scope :without_not_interested, (lambda do |viewing_member|
    not_interested_poll_ids = Member::PollList.new(viewing_member).not_interested_poll_ids
    where('polls.id NOT IN (?)', not_interested_poll_ids) if not_interested_poll_ids.count > 0
  end)

  scope :without_incoming_block, (lambda do |viewing_member|
    incoming_block_ids = Member::MemberList.new(viewing_member).blocked_by_someone
    where('polls.member_id NOT IN (?)', incoming_block_ids) if incoming_block_ids.size > 0
  end)

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

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) do
      @poll = find_by(id: id)
      fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::NOT_FOUND unless @poll.present?
      fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::DELETED unless @poll.deleted_at.nil?
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
    Member::PollInquiry.new(member, self).voted?
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

  # TODO: Get rid of this
  def get_in_groups(groups_by_name)
    group = []
    # split_group_id ||= in_group_ids.split(",").map(&:to_i)
    split_group_id ||= groups.map(&:id)
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

  # TODO: Get rid of this
  def get_within(groups_by_name = {}, action_timeline = {}, group_id = nil)
    @group_id = group_id
    if public && in_group
      Hash["in" => "Group", "group_detail" => get_in_groups(groups_by_name)]
    elsif public
      if action_timeline["friend_following_poll"]
        PollType.to_hash(PollType::WHERE[:friend_following])
      else
        PollType.to_hash(PollType::WHERE[:public])
      end
    else
      if in_group
        Hash["in" => "Group", "group_detail" => get_in_groups(groups_by_name)]
      else
        PollType.to_hash(PollType::WHERE[:friend_following])
      end
    end
  end

  def feed_name_for_member(member, group_id = nil)
    posted_to_hash = poll_is_where

    if in_group
      groups_available = Member::GroupList.new(member).groups_available_for_poll(self, group_id)

      groups_as_json = []
      groups_available.each do |group|
        groups_as_json << GroupDetailSerializer.new(group).as_json
      end

      posted_to_hash["group_detail"] = groups_as_json
    end

    posted_to_hash
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
    campaign.member_rewards.find_by(poll: self, member: member).presence || {}
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

  def self.vote_poll(params, member, data_options = {})
    member_id = params[:member_id]
    surveyor_id = params[:surveyor_id]
    poll_id = params[:id]
    choice_id = params[:choice_id]
    guest_id = params[:guest_id]
    show_result = params[:show_result]

    find_poll = Poll.find_by(id: poll_id)
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::NOT_FOUND if find_poll.nil?
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::UNDER_INSPECTION if find_poll.black?
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::CLOSED if find_poll.closed?
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::EXPIRED if find_poll.expire_date < Time.zone.now

    ever_vote = Member::PollInquiry.new(member, find_poll).voted?
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

    UnseePoll.new({member_id: member.id, poll_id: poll_id}).delete_unsee_poll

    SavePollLater.delete_save_later(member.id, find_poll)

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
    campaign.prediction(member.id, self.id) if (campaign.expire > Time.now) && (campaign.used < campaign.limit) && (campaign.member_rewards.find_by(member_id: member.id, poll_id: self.id).nil?)
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

end
