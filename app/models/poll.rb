class Poll < ActiveRecord::Base
  mount_uploader :photo_poll, PhotoPollUploader


  has_many :choices, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings, source: :tag


  belongs_to :member
  belongs_to :poll_series

  has_many :poll_groups, dependent: :destroy
  has_many :groups, through: :poll_groups, source: :group

  has_many :poll_members, dependent: :destroy
  has_many :members, through: :poll_members, source: :member

  scope :public_poll, -> { where(public: true) }
  scope :active_poll, -> { where("expire_date > ?", Time.now) }
  scope :inactive_poll, -> { where("expire_date < ?", Time.now) }
  scope :load_more, -> (next_poll) { where("id < ?", next_poll) }

  default_scope { order("created_at desc").limit(10) }

  accepts_nested_attributes_for :choices, :allow_destroy => true

  self.per_page = 20

  validates :member_id, :title , presence: true

  def self.get_public_poll(member, option = {})
    list_friend = member.poll_of_friends.map(&:followed_id) << member.id
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

  def find_poll_series(member_id, series_id)
    Poll.includes(:choices).where(member_id: member_id, poll_series_id: series_id).order("id asc")
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

    convert_expire_date = Time.now + expire_date.to_i.days
    set_public = buy_poll || member.celebrity?
    @poll = create(member_id: member_id, title: title, expire_date: convert_expire_date, public: set_public)

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

  def self.vote_poll(poll)
    member_id = poll[:member_id]
    poll_id = poll[:poll_id]
    choice_id = poll[:choice_id]
  
    begin
      ever_vote = HistoryVote.find_by_member_id_and_poll_id(member_id, poll_id)
      unless ever_vote.present?
        find_poll = Poll.find(poll_id)
        find_choice = find_poll.choices.where(id: choice_id).first
        find_poll.increment!(:vote_all)
        find_choice.increment!(:vote)

        history_voted = HistoryVote.create(member_id: member_id, poll_id: poll_id, choice_id: choice_id)
        [find_poll, history_voted]
      end
    rescue => e
      puts "error => #{e}"
      nil
    end    
  end

  def self.view_poll(poll)
    member_id = poll[:member_id]
    poll_id = poll[:poll_id]

    HistoryView.where(member_id: member_id, poll_id: poll_id).first_or_initialize.tap do |history|
      history.member_id = member_id
      history.poll_id = poll_id
      history.save!

      find(poll_id).increment!(:view_all) if find(poll_id).present?
    end
  end
  
end
