class RawVotePoll
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :poll_id, type: Integer
  field :choice_id, type: Integer
  field :age, type: Integer

  index "poll_id" => 1
  index "choice_id" => 1

  def self.store_member_info(poll_id, choice_id, member)
    create!(poll_id: poll_id, choice_id: choice_id, gender: member.gender.value)
  end

end
