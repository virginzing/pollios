class HiddenPoll < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll


  def self.my_hidden_poll(member_id)
    hidden_poll = where("member_id = ?", member_id).pluck(:poll_id)
  end

end
