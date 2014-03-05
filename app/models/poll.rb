class Poll < ActiveRecord::Base
  mount_uploader :photo_poll, PhotoPollUploader
  attr_accessor :group_id, :tag_tokens, :share_poll_of_id
  

  has_many :choices, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings, source: :tag

  has_many :poll_groups, dependent: :destroy
  has_many :groups, through: :poll_groups, source: :group

  has_many :poll_members, dependent: :destroy
  has_many :members, through: :poll_members, source: :member

  has_many :history_votes, dependent: :destroy
  has_many :share_polls, dependent: :destroy

  belongs_to :member, touch: true
  belongs_to :poll_series
  belongs_to :campaign
  belongs_to :recurring

  validates :title, presence: true
  validates :member_id, :title , presence: true
  accepts_nested_attributes_for :choices, :reject_if => lambda { |a| a[:answer].blank? }, :allow_destroy => true

  default_scope { order("created_at desc").limit(LIMIT_POLL) }
  
  scope :public_poll, -> { where(public: true) }
  scope :active_poll, -> { where("expire_date > ?", Time.now) }
  scope :inactive_poll, -> { where("expire_date < ?", Time.now) }
  scope :load_more, -> (next_poll) { where("id < ?", next_poll) }

  LIMIT_POLL = 10
  LIMIT_TIMELINE = 3000
  self.per_page = 20

  amoeba do
    enable
    set [{:vote_all => 0}, {:view_all => 0}, {:vote_all_guest => 0}, {:view_all_guest => 0}, {:favorite_count => 0}, {:share_count => 0} ]
    
    customize(lambda { |original_poll, new_poll|
      new_poll.expire_date = original_poll.expire_date + 1.day
    })

    include_field :choices
  end

  before_save :set_default_value

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
    Rails.cache.fetch([self, 'member'], expires_in: 30.minutes) do
      member.as_json()
    end
  end

  def tag_tokens=(tokens)
    puts "tokens => #{tokens}"
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
    else
      query_poll = Poll.unscoped.includes(:history_votes).where("history_votes.member_id = ? AND history_votes.poll_series_id = 0", member_obj.id).order("history_votes.created_at desc").limit(LIMIT_POLL)
      puts "query poll => #{query_poll}"
    end
    
    @poll = filter_type(query_poll, type)

    if next_cursor.presence && status == ENV["MY_POLL"]
      @poll = @poll.load_more(next_cursor)
    elsif next_cursor.presence && status == ENV["MY_VOTE"]
      @poll = @poll.where("history_votes.id < ?", next_cursor)
    end

    if @poll.count == LIMIT_POLL
      if status == ENV["MY_POLL"]
        next_cursor = @poll.to_a.last.id
      elsif status == ENV["MY_VOTE"]
        next_cursor = HistoryVote.find_by_poll_id(@poll.to_a.last.id).id
      end
    else
      next_cursor = 0
    end

    [@poll, next_cursor]
  end

  def self.cached_find_poll(member_obj, status)
    Rails.cache.fetch([ status, member_obj.id, @type ]) do
      if status == ENV["PUBLIC_POLL"]
        PollMember.timeline(member_obj.id, member_obj.whitish_friend.map(&:followed_id), @type)
      elsif status == ENV["MY_POLL"]
        PollMember.find_my_poll(member_obj.id, @type)
      elsif status == ENV["MY_VOTE"]
          
      end
    end
  end

  def self.list_of_poll(member_obj, status, options = {})
    puts "options =>  #{options}"
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
    puts "cache poll id : #{@cache_polls}"

    if poll.count == LIMIT_POLL
      next_cursor = poll.last
    else
      next_cursor = 0
    end

    if status == ENV["PUBLIC_POLL"]
      filter_poll(poll, next_cursor)
    elsif status == ENV["MY_POLL"]
      filter_my_poll_my_vote(poll, next_cursor)
    end
  end

  def self.filter_poll(poll_ids, next_cursor)
    poll_series = []
    poll_nonseries = []
    series_shared = []
    nonseries_shared = []

    PollMember.includes(:poll, :member).where("id IN (?)", poll_ids).order("id desc").each do |poll_member|
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
    poll_series = []
    poll_nonseries = []
    next_cursor = 0

    list_of_poll.each do |poll|
      if poll.series
        poll_series << poll
      else
        poll_nonseries << poll
      end
    end

    if poll_nonseries.count + poll_series.count == LIMIT_POLL
      cursor_id = poll_nonseries.last.id
      next_cursor = cursor_id
    end

    [poll_series, poll_nonseries, next_cursor]
  end

  def find_poll_series(member_id, series_id)
    Poll.where(member_id: member_id, poll_series_id: series_id).limit(20)
  end

  def self.get_group_poll(member, option = {})
    list_group = member.groups.map(&:id)
    if option[:next_poll]
      Poll.joins(:groups).where("groups.id IN (?)", list_group).includes(:member, :choices).where("id < ?", option[:next_poll])
    else  
      Poll.joins(:groups).where("groups.id IN (?)", list_group).includes(:member, :choices)
    end
  end

  def self.create_poll(poll, member)
    title = poll[:title]
    expire_date = poll[:expire_date]
    choices = poll[:choices]
    group_id = poll[:group_id]
    member_id = poll[:member_id]
    friend_id = poll[:friend_id]
    buy_poll = poll[:buy_poll]
    choice_count = get_choice_count(poll[:choices])

    convert_expire_date = Time.now + expire_date.to_i.days
    set_public = buy_poll || member.celebrity?
    @poll = create(member_id: member_id, title: title, expire_date: convert_expire_date, public: set_public, poll_series_id: 0, series: false, choice_count: choice_count)

    if @poll.valid? && choices
      list_choice = choices.split(",")
      @choices = Choice.create_choices(@poll.id ,list_choice)

      if @choices.present?
        if group_id
          Group.add_poll(@poll.id, group_id)
        else
          @poll.poll_members.create!(member_id: member_id, share_poll_of_id: 0, public: set_public, series: false, expire_date: convert_expire_date)
        end
      end
    end
    @poll
  end

  def self.get_choice_count(choices)
    choices.split(",").count if choices.presence
  end

  def self.vote_poll(poll)
    member_id = poll[:member_id]
    poll_id = poll[:id]
    choice_id = poll[:choice_id]
    guest_id = poll[:guest_id]

    begin
      ever_vote = guest_id.present? ? HistoryVoteGuest.find_by_guest_id_and_poll_id(guest_id, poll_id) : HistoryVote.find_by_member_id_and_poll_id(member_id, poll_id)
      unless ever_vote.present?
        find_poll = Poll.find(poll_id)
        find_choice = find_poll.choices.where(id: choice_id).first

        if find_poll.series
          poll_series_id = find_poll.poll_series_id
        else
          poll_series_id = 0
        end

        if guest_id.present?
          find_poll.increment!(:vote_all_guest)
          find_choice.increment!(:vote_guest)
          find_poll.poll_series.increment!(:vote_all_guest) if find_poll.series
          history_voted = HistoryVoteGuest.create(guest_id: guest_id, poll_id: poll_id, choice_id: choice_id)
        else
          find_poll.increment!(:vote_all)
          find_choice.increment!(:vote)
          find_poll.poll_series.increment!(:vote_all) if find_poll.series
          history_voted = HistoryVote.create(member_id: member_id, poll_id: poll_id, choice_id: choice_id, poll_series_id: poll_series_id)
        end

        # Campaign.manage_campaign(find_poll.id, member_id) if find_poll.campaign_id.present?

        [find_poll, history_voted]
      end
    rescue => e
      puts "error => #{e}"
      nil
    end  

  end

  def self.view_poll(poll)
    member_id = poll[:member_id]
    poll_id = poll[:id]
    guest_id = poll[:guest_id]

    ever_view = guest_id.present? ? HistoryViewGuest.where(guest_id: guest_id, poll_id: poll_id).first.present? : HistoryView.where(member_id: member_id, poll_id: poll_id).first.present?
    unless ever_view.present?

      if guest_id.present?
        HistoryViewGuest.create!(guest_id: guest_id, poll_id: poll_id)
        find(poll_id).increment!(:view_all_guest)
        find(poll_id).poll_series.increment!(:view_all_guest) if find(poll_id).series
      else
        HistoryView.create!(member_id: member_id, poll_id: poll_id)
        find(poll_id).increment!(:view_all)
        find(poll_id).poll_series.increment!(:view_all) if find(poll_id).series
      end

    end

  end

  def get_choice_scroll
    choices.collect! {|choice| choice.vote }
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

end



