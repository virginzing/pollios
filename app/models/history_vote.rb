class HistoryVote < ActiveRecord::Base
  belongs_to :member, touch: true
  belongs_to :poll
  belongs_to :choice
  
  store_accessor :data_analysis

  validates :poll_id, :member_id, :choice_id, presence: true

  default_scope { order("id desc") }

  def self.voted?(member, poll_id)
    cached_history_voted = member.cached_my_voted

    ever_voted = cached_history_voted.select! {|voted| voted.poll_id == poll_id }

    if ever_voted.empty?
      {
        "voted" => false
      }
    else
      {
        "voted" => true, 
        "choice_id" => ever_voted[0].choice_id
      }
    end
  end

end