class PollSeries < ActiveRecord::Base

  attr_accessor :tag_tokens

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
    polls.collect{ |poll| poll.update(expire_date: self.expire_date, series: true, choice_count: poll.choices.count, public: true ) }
    PollMember.create!(member_id: self.member_id, poll_id: polls.last.id)
  end

  def cached_tags
    Rails.cache.fetch([self, 'tags']) do
      tags.pluck(:name)
    end
  end

end
