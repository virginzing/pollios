class HistoryVote < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll

  validates :poll_id, :member_id, :choice_id, presence: true

  default_scope { order("id desc") }

  def self.voted?(member_id, poll_id)
    history_voted = where(member_id: member_id, poll_id: poll_id).first
    if history_voted.present?
      {
        "voted" => true, 
        "choice_id" => history_voted.choice_id
      }
    else
      {
        "voted" => false
      }
    end
  end

end