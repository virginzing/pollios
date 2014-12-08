class UnSeePoll < ActiveRecord::Base
  belongs_to :member
  belongs_to :unseeable, polymorphic: true

  def self.get_my_unsee(member_id)
    where(member_id: member_id)
  end
end
