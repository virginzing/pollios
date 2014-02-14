class PollSeries < ActiveRecord::Base
  belongs_to :member
  has_many :polls, dependent: :destroy

  validates :description, presence: true

  accepts_nested_attributes_for :polls, :allow_destroy => true

  self.per_page = 10

  after_create :set_poll_series

  def set_poll_series
    self.number_of_poll = polls.count
    self.save
    polls.collect{ |poll| poll.update(expire_date: self.expire_date, series: true, choice_count: poll.choices.count, public: true ) }
    PollMember.create!(member_id: self.member_id, poll_id: polls.last.id)
  end
end
