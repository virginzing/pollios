class PollSeries < ActiveRecord::Base
  include PollSeriesHelper
  attr_accessor :tag_tokens, :same_choices, :expire_within

  belongs_to :member
  belongs_to :campaign
  
  has_many :polls, dependent: :destroy
  has_many :suggests, dependent: :destroy

  has_many :history_view_questionnaires, dependent: :destroy
  has_many :poll_series_tags, dependent: :destroy
  has_many :tags, through: :poll_series_tags, source: :tag

  validates :description, presence: true

  accepts_nested_attributes_for :polls, :allow_destroy => true

  self.per_page = 10

  after_create :set_poll_series
  after_create :generate_qrcode_key

  def generate_qrcode_key
    begin
      self.qrcode_key = SecureRandom.hex(4)
    end while PollSeries.exists?(qrcode_key: qrcode_key)
    self.update(qrcode_key: qrcode_key)
  end

  def tag_tokens=(tokens)
    puts "tokens => #{tokens}"
    self.tag_ids = Tag.ids_from_tokens(tokens)
  end

  def creator 
    member.as_json(only: [:id, :fullname, :avatar])
  end

  def set_poll_series
    in_group = false
    self.number_of_poll = polls.count
    self.save
    list_choice = self.same_choices

    polls.order("id asc").each do |poll|
      if list_choice.present?
        list_choice.collect{ |answer| poll.choices.create!(answer: answer) }
        choices_count = list_choice.count
      else
        choices_count = poll.choices.count
      end
      poll.update!(expire_date: expire_date, series: true, choice_count: choices_count, public: self.public, in_group_ids: self.in_group_ids, member_type: Member.find(self.member_id).member_type_text)
    end

    if self.in_group_ids != "0"
      in_group = true
    end

    unless self.qr_only
      PollMember.create!(member_id: self.member_id, poll_id: polls.last.id, share_poll_of_id: 0, public: self.public, series: true, expire_date: expire_date, in_group: in_group)
    end
  end

  def cached_tags
    Rails.cache.fetch([self, 'tags']) do
      tags.pluck(:name)
    end
  end

  def self.view_poll(member, poll_series)
    member_id = member.id
    poll_series_id = poll_series.id

    used_to_view_qn = HistoryViewQuestionnaire.where(member_id: member_id, poll_series_id: poll_series_id).first_or_create do |hqn|
      hqn.member_id = member_id
      hqn.poll_series_id = poll_series_id
      hqn.save!
      poll_series.update_columns(view_all: poll_series.view_all + 1)
    end
  end

  def vote_questionnaire(params, member, poll_series)
    PollSeries.transaction do
      list_answer = params[:answer].collect!{ |poll| poll.merge({ :member_id => params[:member_id]}) }
      list_answer.each do |answer|
        @votes = Poll.vote_poll(answer, member)
      end

      if @votes.present?
        increment!(:vote_all)
        poll_series.suggests.create!(member_id: member.id, message: params[:suggest])
        # Activity.create_activity_poll_series(member, poll_series, 'Vote')
      end
      @votes
    end
  end

  def as_json options={}
    { creator: polls.first.cached_member,
      list_of_poll: {
        id: id,
        vote_count: vote_all,
        view_count: view_all,
        expire_date: expire_date,
        created_at: created_at.to_i,
        title: description,
        series: true,
        tags: cached_tags,
        share_count: share_count,
        poll: polls.as_json()
      }
    }
  end

end
