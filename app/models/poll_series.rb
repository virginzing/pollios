class PollSeries < ActiveRecord::Base

  attr_accessor :tag_tokens, :same_choices

  belongs_to :member
  belongs_to :campaign
  
  has_many :polls, dependent: :destroy

  has_many :poll_series_tags, dependent: :destroy
  has_many :tags, through: :poll_series_tags, source: :tag

  validates :description, presence: true

  accepts_nested_attributes_for :polls, :allow_destroy => true

  self.per_page = 10

  after_create :set_poll_series

  def tag_tokens=(tokens)
    puts "tokens => #{tokens}"
    self.tag_ids = Tag.ids_from_tokens(tokens)
  end

  def creator 
    member.as_json(only: [:id, :sentai_name, :avatar])
  end

  def set_poll_series
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
      poll.update(expire_date: self.expire_date, series: true, choice_count: choices_count, public: true )
    end

    PollMember.create!(member_id: self.member_id, poll_id: polls.last.id, share_poll_of_id: 0, public: true, series: true, expire_date: self.expire_date)
  end

  def cached_tags
    Rails.cache.fetch([self, 'tags']) do
      tags.pluck(:name)
    end
  end

  def vote_questionnaire(params)
    list_answer = params[:answer].collect!{ |poll| poll.merge({ :member_id => params[:member_id]}) }
    list_answer.each do |answer|
      @votes = Poll.vote_poll(answer)
    end

    if @votes.present?
      increment!(:vote_all)
      increment!(:view_all)
    end
    @votes
  end

end
