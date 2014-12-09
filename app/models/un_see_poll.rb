class UnSeePoll < ActiveRecord::Base
  belongs_to :member
  belongs_to :unseeable, polymorphic: true

  def self.get_my_unsee(member_id)
    where(member_id: member_id)
  end

  def self.get_only_poll_id(list_un_see)
    list_un_see.select{|e| e if e.unseeable_type == "Poll" }.map(&:unseeable_id)
  end

  def self.get_only_questionnaire_id(list_un_see)
    list_un_see.select{|e| e if e.unseeable_type == "PollSeries" }.map(&:unseeable_id)
  end
end
