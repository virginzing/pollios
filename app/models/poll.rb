class Poll < ActiveRecord::Base
  mount_uploader :photo_poll, PhotoPollUploader
  include PgSearch
  include PollsHelper

  attr_accessor :group_id, :tag_tokens, :share_poll_of_id, :choice_one, :choice_two, :choice_three
  cattr_accessor :custom_error_message

  pg_search_scope :search_with_tag, against: [:title],
    using: { tsearch: {dictionary: "english", prefix: true} },
    associated_against: {tags: [:name]}

  has_many :choices, inverse_of: :poll, dependent: :destroy
  has_many :taggings, dependent: :destroy

  has_many :tags, through: :taggings, source: :tag

  has_many :watcheds, dependent: :destroy
  has_many :watched_by_member, through: :watcheds, source: :member

  has_many :poll_groups, dependent: :destroy
  has_many :groups, through: :poll_groups, source: :group

  has_many :poll_members, dependent: :destroy
  has_many :members, through: :poll_members, source: :member

  has_many :campaign_members, dependent: :destroy

  has_many :comments, dependent: :destroy

  has_many :history_votes, dependent: :destroy
  has_many :history_views, dependent: :destroy
  has_many :share_polls, dependent: :destroy
  has_many :hidden_polls, dependent: :destroy

  has_many :member_report_polls, dependent: :destroy

  belongs_to :member, touch: true
  belongs_to :poll_series
  belongs_to :campaign
  belongs_to :recurring

  before_save :set_default_value
  before_create :generate_qrcode_key

  after_create :set_new_title_with_tag
  after_commit :flush_cache

  validates :title, :member_id, presence: true

  accepts_nested_attributes_for :choices, :reject_if => lambda { |a| a[:answer].blank? }, :allow_destroy => true

  default_scope { order("#{table_name}.created_at desc") }

  scope :public_poll, -> { where(public: true) }
  scope :active_poll, -> { where("expire_date > ?", Time.zone.now) }
  scope :inactive_poll, -> { where("expire_date < ?", Time.zone.now) }
  scope :load_more, -> (next_poll) { where("id < ?", next_poll) }

  scope :available, -> {
    member_report_poll = Member.reported_polls.map(&:id)  ## poll ids
    member_block = Member.list_friend_block.map(&:id)  ## member ids

    if member_report_poll.present? && member_block.present?
      having_status_poll(:gray, :white).where("#{table_name}.id NOT IN (?) AND #{table_name}.member_id NOT IN (?)", member_report_poll, member_block)
    elsif member_report_poll.present?
      having_status_poll(:gray, :white).where("#{table_name}.id NOT IN (?)", member_report_poll)
    elsif member_block.present?
      having_status_poll(:gray, :white).where("#{table_name}.member_id NOT IN (?)", member_block)
    else
      having_status_poll(:gray, :white)
    end
  }

  scope :have_vote, -> { where("polls.vote_all > 0") }
  scope :unexpire, -> {
    where("polls.expire_status = 'f'")
  }

  LIMIT_POLL = 10
  LIMIT_TIMELINE = 3000

  self.per_page = 10

  amoeba do
    enable
    set [{:vote_all => 0}, {:view_all => 0}, {:vote_all_guest => 0}, {:view_all_guest => 0}, {:favorite_count => 0}, {:share_count => 0} ]

    customize(lambda { |original_poll, new_poll|
                new_poll.expire_date = original_poll.expire_date + 1.day
                new_poll.created_at = Time.now
    })

    include_field :choices
  end

  def self.cached_find(id)
    begin
      raise ExceptionHandler::NotFound, "Poll not found or deleted." unless find_by(id: id).present?
      Rails.cache.fetch([name, id]) { find(id) }
    end
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
    self.member.flush_cache_my_poll
    self.member.flush_cache_my_watch
    self.member.flush_cache_my_vote
    self.member.flush_cache_my_vote_all
  end

  def cached_choices
    Rails.cache.fetch([self, 'choices']) do
      choices.to_a
    end
  end

  # def flush_cache_relate_with_vote
  #   FlushCachePollVoteWorker.perform_async(history_votes.map(&:member_id).uniq)
  # end

  # def flush_cache_relate_with_watch
  #   FlushCachePollWatchWorker.perform_async(watcheds.map(&:member_id).uniq)
  # end

  def get_poll_in_groups(group_ids)
    groups.includes(:groups).where("poll_groups.group_id IN (?)", group_ids)
  end

  def set_new_title_with_tag
    poll_title = self.title
    tags.pluck(:name).each do |tag|
      poll_title = poll_title + " " + "#" + tag
    end
    update_attributes!(title: poll_title)
  end

  def generate_qrcode_key
    begin
      self.qrcode_key = SecureRandom.hex(4)
    end while self.class.exists?(qrcode_key: qrcode_key)
  end

  # def get_vote_max
  #   # max = choices.collect{|choice| Hash["answer" => choice.answer, "vote" => choice.vote]}.max_by {|k, v| k["vote"]}
  #   @choice ||= cached_choices
  #   # max = @choice.map(&:vote).max
  #   @choice.collect {|c| Hash["answer" => c.answer, "vote" => c.vote, "choice_id" => c.id] if c.vote == max }.compact
  # end

  def get_vote_max
    @choice ||= cached_choices
    @choice.sort {|x,y| y["vote"] <=> x["vote"] }[0..1].collect{|c| Hash["answer" => c.answer, "vote" => c.vote, "choice_id" => c.id ] }.compact
  end

  def get_choice_detail
    @choice ||= cached_choices
    hash_choice = []
    cached_choices.each do |choice|
      hash_choice << {"choice_id" => choice.id, "answer" => choice.answer, "vote" => choice.vote }
    end
    hash_choice
  end

  def get_in_groups(groups_by_name)
    group = []
    split_group_id ||= in_group_ids.split(",").collect{|e| e.to_i }

    split_group_id.each do |id|
      if groups_by_name.has_key?(id)
        group << groups_by_name.fetch(id)
      end
    end

    if group.empty?
      find_group = Group.where("id IN (?)", split_group_id).first
      group << Hash["id" => find_group.id, "name" => find_group.name, "photo" => find_group.get_photo_group]
    end

    group
  end

  def get_within(options = {}, action_timeline = {})
    if public
      if action_timeline["friend_following_poll"]
        PollType.to_hash(PollType::WHERE[:friend_following])
      else
        PollType.to_hash(PollType::WHERE[:public])
      end
    else
      if in_group != true
        PollType.to_hash(PollType::WHERE[:friend_following])
      else
        Hash["in" => "Group", "group_detail" => get_in_groups(options)]
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
    Rails.cache.fetch([self, 'tags']) do
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

  def get_campaign_detail
    campaign.as_json()
  end

  def get_photo
    photo_poll.url(:medium).presence || ""
  end

  def tag_tokens=(tokens)
    self.tag_ids = Tag.ids_from_tokens(tokens)
  end

  def self.tag_counts
    Tag.joins(:taggings).select("tags.*, count(tag_id) as count").group("tags.id")
  end

  # def tag_list
  #   tags.map(&:name).join(",")
  # end

  def self.get_public_poll(member, option = {})
    list_friend = member.whitish_friend.map(&:followed_id) << member.id
    query_poll = Poll.includes(:member, :choices).where("member_id IN (?) OR public = ?", list_friend, true)

    if option[:next_poll]
      if option[:type] == "active"
        query_poll.active_poll.load_more(option[:next_poll])
      elsif option[:type] == "inactive"
        query_poll.inactive_poll.load_more(option[:next_poll])
      else
        query_poll.load_more(option[:next_poll])
      end
    else
      if option[:type] == "active"
        query_poll.active_poll
      elsif option[:type] == "inactive"
        query_poll.inactive_poll
      else
        query_poll
      end
    end
  end

  def self.get_my_vote_my_poll(member_obj, status, options = {})
    next_cursor = options[:next_cursor]
    type = options[:type]
    if status == ENV["MY_POLL"]
      query_poll = member_obj.get_my_poll
    end

    @poll = filter_type(query_poll, type)

    if next_cursor.presence && status == ENV["MY_POLL"]
      @poll = @poll.load_more(next_cursor)
    end

    if @poll.count == LIMIT_POLL
      if status == ENV["MY_POLL"]
        next_cursor = @poll.to_a.last.id
      end
    else
      next_cursor = 0
    end

    [@poll, next_cursor]
  end

  def self.cached_find_poll(member_obj, status)
    puts "status => #{status}"

    Rails.cache.fetch([ status, member_obj.id, @type ]) do
      if status == ENV["PUBLIC_POLL"]
        PollMember.timeline(member_obj.id, member_obj.whitish_friend.map(&:followed_id), @type)
      elsif status == ENV["FRIEND_FOLLOWING_POLL"]
        PollMember.friend_following_timeline(member_obj, member_obj.id, member_obj.whitish_friend.map(&:followed_id), @type)
      elsif status == ENV["MY_POLL"]
        PollMember.find_my_poll(member_obj.id, @type)
      else

      end
    end
  end

  def self.list_of_poll(member_obj, status, options = {})
    # puts "options =>  #{options}"
    next_cursor = options[:next_cursor]
    @type = options[:type]

    if next_cursor.presence && next_cursor != "0"
      next_cursor = next_cursor.to_i
      @cache_polls = cached_find_poll(member_obj, status)
      index = @cache_polls.index(next_cursor)
      index = -1 if index.nil?
      poll = @cache_polls[(index+1)..(LIMIT_POLL+index)]
    else
      Rails.cache.delete([status, member_obj.id, @type])
      @cache_polls = cached_find_poll(member_obj, status)
      poll = @cache_polls[0..(LIMIT_POLL - 1)]
    end

    if @cache_polls.count > LIMIT_POLL
      if poll.count == LIMIT_POLL
        if @cache_polls[-1] == poll.last
          next_cursor = 0
        else
          next_cursor = poll.last
        end
      else
        next_cursor = 0
      end
    else
      next_cursor = 0
    end

    if status == ENV["PUBLIC_POLL"]
      filter_poll(poll, next_cursor)
    elsif status == ENV["FRIEND_FOLLOWING_POLL"]
      filter_poll(poll, next_cursor)
    elsif status == ENV["MY_POLL"]
      filter_my_poll_my_vote(poll, next_cursor)
    else

    end
  end

  def self.filter_poll(poll_ids, next_cursor)
    poll_series = []
    poll_nonseries = []
    series_shared = []
    nonseries_shared = []
    poll_member = PollMember.includes([{:poll => [:choices, :campaign, :poll_series, :member]}]).where("id IN (?)", poll_ids).order("id desc")

    poll_member.each do |poll_member|
      if poll_member.share_poll_of_id == 0
        not_shared = Hash["shared" => false]
        if poll_member.poll.series
          poll_series << poll_member.poll
          series_shared << not_shared
        else
          poll_nonseries << poll_member.poll
          nonseries_shared << not_shared
        end
      else
        find_poll = Poll.find_by(id: poll_member.share_poll_of_id)
        shared = Hash["shared" => true, "shared_by" => poll_member.member.as_json()]
        if find_poll.present?
          if find_poll.series
            poll_series << find_poll
            series_shared << shared
          else
            poll_nonseries << find_poll
            nonseries_shared << shared
          end
        end
      end
    end
    # puts "poll nonseries : #{poll_nonseries}"
    # puts "share nonseries: #{nonseries_shared}"
    [poll_series, series_shared, poll_nonseries, nonseries_shared, next_cursor]
  end

  def self.filter_my_poll_my_vote(poll_ids, next_cursor)
    poll_series = []
    poll_nonseries = []

    Poll.includes(:member).where("id IN (?)", poll_ids).order("id desc").each do |poll|
      if poll.series
        poll_series << poll
      else
        poll_nonseries << poll
      end
    end

    [poll_series, poll_nonseries, next_cursor]
  end

  def self.split_poll(list_of_poll)
    # puts "list_of_poll => #{list_of_poll.to_a.map(&:id)}"
    poll_series = []
    poll_nonseries = []

    list_of_poll.each do |poll|
      if poll.series
        poll_series << poll
      else
        poll_nonseries << poll
      end
    end

    [poll_series, poll_nonseries]

    # puts "poll_series #{poll_series.map(&:id)}"
    # puts "poll_nonseries #{poll_nonseries.map(&:id)}"
  end


  def find_poll_series(member_id, series_id)
    Poll.where(member_id: member_id, poll_series_id: series_id).order("id asc")
  end

  def self.get_group_poll(member, option = {})
    list_group = member.groups.map(&:id)
    if option[:next_poll]
      Poll.joins(:groups).where("groups.id IN (?)", list_group).includes(:member, :choices).where("id < ?", option[:next_poll])
    else
      Poll.joins(:groups).where("groups.id IN (?)", list_group).includes(:member, :choices)
    end
  end

  def self.create_poll(poll, member) ## create poll for API
    Poll.transaction do
      begin
        # puts "test log allow commnet => #{poll[:allow_comment]}"
        title = poll[:title]
        expire_date = poll[:expire_within]
        choices = poll[:choices]
        group_id = poll[:group_id]
        member_id = poll[:member_id]
        friend_id = poll[:friend_id]
        # buy_poll = poll[:buy_poll] || false
        type_poll = poll[:type_poll]
        is_public = poll[:is_public] || "0"
        photo_poll = poll[:photo_poll]
        allow_comment = poll[:allow_comment] || false
        creator_must_vote = poll[:creator_must_vote]
        require_info = poll[:require_info].present? ? true : false
        show_result = poll[:show_result].present? ? true : false

        choices = check_type_of_choice(choices)

        choice_count = get_choice_count(choices)
        in_group_ids = group_id.presence || "0"
        in_group = group_id.present? ? true : false

        if expire_date.present?
          convert_expire_date = Time.now + expire_date.to_i.day
        else
          convert_expire_date = Time.now + 100.years.to_i
        end

        raise ArgumentError, "Point remain 0" if (member.citizen? && is_public == "1") && (member.point <= 0)
        
        if in_group
          if (member.post_poll_in_group(in_group_ids).count > 0  && in_group)
            list_group_id = member.post_poll_in_group(in_group_ids)
          else
            raise ExceptionHandler::Forbidden, "You are not a member of this group" 
          end
        end

        if group_id.present?
          @set_public = false
        else
          if (is_public == "1" || member.celebrity? || member.brand?)
            @set_public = true
            if is_public == "0"
              @set_public = false
            end
          else
            @set_public = false
          end
        end

        @poll = create!(member_id: member_id, title: title, expire_date: convert_expire_date, public: @set_public, poll_series_id: 0, series: false, choice_count: choice_count, in_group_ids: in_group_ids,
                        type_poll: type_poll, photo_poll: photo_poll, status_poll: 0, allow_comment: allow_comment, member_type: member.member_type_text, creator_must_vote: creator_must_vote, require_info: require_info, in_group: in_group)

        if @poll.valid? && choices
          @choices = Choice.create_choices(@poll.id, choices)
          if @choices.present?

            @poll.create_tag(title)

            @poll.create_watched(member, @poll.id)

            if group_id
              Group.add_poll(member, @poll, list_group_id)
              @poll.poll_members.create!(member_id: member_id, share_poll_of_id: 0, public: @set_public, series: false, expire_date: convert_expire_date, in_group: true)
            else
              @poll.poll_members.create!(member_id: member_id, share_poll_of_id: 0, public: @set_public, series: false, expire_date: convert_expire_date)
              ApnPollWorker.perform_in(5.second, member_id.to_i, @poll.id)
            end

            if member.citizen? && is_public == "1"
              member.decrement!(:point) if member.point > 0
            end

            PollStats.create_poll_stats(@poll)

            Activity.create_activity_poll(member, @poll, 'Create')

            [@poll, nil]
          end
        else
          [nil, @poll.errors.full_messages]
        end

      rescue ArgumentError => detail
        [@poll = nil, detail.message]
      end ## begin

    end ## transaction
    # puts "have poll #{@poll}"
  end

  def self.check_type_of_choice(choices)
    unless choices.class == Array
      choices = choices.split(",")
    end
    choices
  end

  def create_watched(member, poll_id)
    WatchPoll.new(member, poll_id).watching
  end

  def self.get_choice_count(choices)
    # choices.each_value.count
    choices.count
  end

  def create_tag(title)
    split_tags = []
    title.gsub(/\B#([[:word:]]+)/) { split_tags << $1 }
    if split_tags.count > 0
      tag_list = []
      split_tags.each do |tag_name|
        tag_list << Tag.find_or_create_by(name: tag_name).id
      end
      self.tag_ids = tag_list
    end
  end

  def self.vote_poll(poll, member, data_options = {})
    member_id = poll[:member_id]
    poll_id = poll[:id]
    choice_id = poll[:choice_id]
    guest_id = poll[:guest_id]

    Poll.transaction do
      begin
        ever_vote = guest_id.present? ? HistoryVoteGuest.find_by_guest_id_and_poll_id(guest_id, poll_id) : HistoryVote.find_by_member_id_and_poll_id(member_id, poll_id)

        unless ever_vote.present?
          find_poll = Poll.cached_find(poll_id)
          find_choice = find_poll.choices.find_by(id: choice_id)

          raise ExceptionHandler::NotFound, "Poll not found" unless find_poll.present?
          raise ExceptionHandler::NotFound, "Choice not found" unless find_choice.present?

          if find_poll.series
            poll_series_id = find_poll.poll_series_id
          else
            poll_series_id = 0
          end

          if guest_id.present?
            find_poll.increment!(:vote_all_guest)
            find_choice.increment!(:vote_guest)
            # find_poll.poll_series.increment!(:vote_all_guest) if find_poll.series
            history_voted = HistoryVoteGuest.create(guest_id: guest_id, poll_id: poll_id, choice_id: choice_id)
          else
            @voted = find_poll.increment!(:vote_all)
            if @voted.present?
              find_choice.increment!(:vote)
              # find_poll.poll_series.increment!(:vote_all) if find_poll.series
              history_voted = member.history_votes.create(poll_id: poll_id, choice_id: choice_id, poll_series_id: poll_series_id, data_analysis: data_options)

              @campaign, @message = find_poll.find_campaign_for_predict?(member_id, poll_id) if find_poll.campaign_id != 0
              # RawVotePoll.store_member_info(find_poll, find_choice, Member.find(member_id)) if find_poll.member.brand?
              get_anonymous = member.get_anonymous_with_poll(find_poll)

              if (member_id.to_i != find_poll.member.id) && !find_poll.series
                VotePollWorker.perform_async(member_id, poll_id, get_anonymous)
              end
              # Campaign.manage_campaign(find_poll.id, member_id) if find_poll.campaign_id.present?

              VoteStats.create_vote_stats(find_poll) unless find_poll.series

              Activity.create_activity_poll(member, find_poll, 'Vote') unless find_poll.series

              member.flush_cache_my_vote
              member.flush_cache_my_vote_all

              Rails.cache.delete([find_poll.class.name, find_poll.id])
              [find_poll, history_voted, @campaign, @message]
            end
          end

        end
        # rescue => e
        #   puts "error => #{e}"
        #   [@error_message = e.message, nil]
      end
    end
  end

  # {"birthday"=>"Jan 15, 1990", "gender"=>1, "salary"=>3, "interests"=>[3, 2, 1], "province"=>27}

  def self.new_hash_for_analysis(hash_analysis)
    # puts "hash_analysis => #{hash_analysis.present?}"
    if hash_analysis.present?
      new_hash = {}
      list_gender ||= Member.gender.values.collect{|e| [e.value, e.text]}
      list_salary ||= Member.salary.values.collect{|e| [e.value, e.text]}
      list_provice ||= Member.province.values.collect{|e| [e.value, e.text]}

      hash_analysis.each do |key, value|
        if key == "gender"
          compare = list_gender.select{|e| e.first == value.to_i }.first.last
          new_hash.merge!(key => compare)
        elsif key == "salary"
          compare = list_salary.select{|e| e.first == value.to_i }.first.last
          new_hash.merge!(key => compare)
        elsif key == "province"
          compare = list_provice.select{|e| e.first == value.to_i }.first.last
          new_hash.merge!(key => compare)
        elsif key == "birthday"
          new_hash.merge!(key => value)
        end
      end
      # puts "new hash => #{new_hash}"
      return new_hash
    end
  end

  def find_campaign_for_predict?(member_id, poll_id)
    campaign.prediction(member_id, poll_id) if campaign.expire > Time.now && campaign.used <= campaign.limit
  end

  def self.view_poll(poll, member)
    HistoryView.transaction do
      begin
        @poll = poll
        @member = member

        find_history_view = @member.history_views.where(poll_id: @poll.id).first

        unless find_history_view.present?
          @member.history_views.create!(poll_id: @poll.id)
          @poll.update_columns(view_all: @poll.view_all + 1)
        end

        # ever_view = true

        # HistoryView.where(member_id: @member.id, poll_id: @poll.id).first_or_create do |hv|
        #   hv.member_id = @member.id
        #   hv.poll_id = @poll.id
        #   hv.save!
        #   ever_view = false
        # end

        # if ever_view.present?
        #   @poll.update_columns(view_all: @poll.view_all + 1)
        # end
      end
    end
  end

  def get_choice_scroll
    choices.collect! {|choice| choice.vote }
  end

  def get_require_info
    require_info.present? ? true : false
  end

  def self.filter_type(query, type)
    case type
    when "active" then query.active_poll
    when "inactive" then query.inactive_poll
    else query
    end
  end

  def self.get_poll_hourly
    hour = Time.zone.now.hour
    start_time = Time.new(2000, 01, 01, hour, 00, 00)
    end_time = start_time.change(min: 59, sec: 59)
    @recurring = Recurring.where("(period BETWEEN ? AND ?) AND end_recur > ?", start_time.to_s, end_time.to_s, Time.zone.now).having_status(:active)
    if @recurring.count > 0
      Recurring.re_create_poll(@recurring)
    end
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
    watched_poll_ids = Member.watched_polls.map(&:id)
    # puts "watched_poll_ids => #{watched_poll_ids}"
    if watched_poll_ids.include?(id)
      true
    else
      false
    end
  end

  def get_expire_date
    expire_date.present? ? expire_date.to_i : ""
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

  def self.total_grouped_by_date(start)
    polls = where(created_at: start.beginning_of_day..Time.zone.now)
    polls = polls.select("date(created_at) as created_at, count(*) as total_poll")
    polls = polls.group("date(created_at)")

    polls.each_with_object({}) do |poll, hsh|
      hsh[poll.created_at.to_date] = poll.total_poll
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

    # puts "read from cached #{@find_member_cached}"
    # member_as_json = Member.serializer_member_hash(@find_member_cached)
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
