class Poll < ActiveRecord::Base
  mount_uploader :photo_poll, PhotoPollUploader

  attr_accessor :group_id, :tag_tokens

  has_many :choices, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings, source: :tag

  has_many :poll_groups, dependent: :destroy
  has_many :groups, through: :poll_groups, source: :group

  has_many :poll_members, dependent: :destroy
  has_many :members, through: :poll_members, source: :member

  belongs_to :member
  belongs_to :poll_series
  belongs_to :campaign

  validates :title, presence: true

  scope :public_poll, -> { where(public: true) }
  scope :active_poll, -> { where("expire_date > ?", Time.now) }
  scope :inactive_poll, -> { where("expire_date < ?", Time.now) }
  scope :load_more, -> (next_poll) { where("id < ?", next_poll) }

  LIMIT_POLL = 1000
  self.per_page = 20

  default_scope { order("created_at desc").limit(LIMIT_POLL) }

  accepts_nested_attributes_for :choices, :reject_if => lambda { |a| a[:answer].blank? }, :allow_destroy => true

  validates :member_id, :title , presence: true



  def tag_tokens=(tokens)
    puts "tokens => #{tokens}"
    self.tag_ids = Tag.ids_from_tokens(tokens)
  end

  def cached_tags
    Rails.cache.fetch([self, 'tags']) do
      tags.pluck(:name)
    end
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

  def self.split_poll(list_of_poll)

    poll_series = []
    poll_nonseries = []
    next_cursor = ""
    list_of_poll.each do |poll|
      if poll.series
        poll_series << poll
      else
        poll_nonseries << poll
      end
    end

    if poll_nonseries.count + poll_series.count == LIMIT_POLL
      # cursor_id = PollMember.find_by_poll_id(poll_nonseries.last).id
      cursor_id = poll_nonseries.last.id
      next_cursor = "#{cursor_id}"
    end

    [poll_series, poll_nonseries, next_cursor]
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

  def self.create_poll(poll, member)
    title = poll[:title]
    expire_date = poll[:expire_date]
    choices = poll[:choices]
    group_id = poll[:group_id]
    member_id = poll[:member_id]
    friend_id = poll[:friend_id]
    buy_poll = poll[:buy_poll]
    poll_series_id = poll[:poll_series_id]
    series = poll[:series]
    choice_count = get_choice_count(poll[:choices])

    convert_expire_date = Time.now + expire_date.to_i.days
    set_public = buy_poll || member.celebrity?
    @poll = create(member_id: member_id, title: title, expire_date: convert_expire_date, public: set_public, poll_series_id: poll_series_id, series: series, choice_count: choice_count)

    if @poll.valid? && choices
      list_choice = choices.split(",")
      @choices = Choice.create_choices(@poll.id ,list_choice)

      if @choices.present?
        if group_id
          Group.add_poll(@poll.id, group_id)
        else
          @poll.poll_members.create!(member_id: member_id)
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

        if guest_id.present?
          find_poll.increment!(:vote_all_guest)
          find_choice.increment!(:vote_guest)
          find_poll.poll_series.increment!(:vote_all_guest) if find_poll.series
          history_voted = HistoryVoteGuest.create(guest_id: guest_id, poll_id: poll_id, choice_id: choice_id)
        else
          find_poll.increment!(:vote_all)
          find_choice.increment!(:vote)
          find_poll.poll_series.increment!(:vote_all) if find_poll.series
          history_voted = HistoryVote.create(member_id: member_id, poll_id: poll_id, choice_id: choice_id)
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

end
