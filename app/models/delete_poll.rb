class DeletePoll
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :creator, type: Hash
  field :poll, type: Hash
  field :voter, type: Array
  field :delete_at, type: Time, default: -> { Time.now }



  def self.create_log(poll)
    if (poll.vote_all > 0 || poll.view_all > 0)
      voter = ActiveModel::ArraySerializer.new(poll.history_votes, each_serializer: VoterFordeleteSerializer).as_json()
      DeletePoll.create!(creator: poll.member.as_json(), poll: PollForDeleteSerializer.new(poll).as_json(), voter: voter)
    end
  end

end