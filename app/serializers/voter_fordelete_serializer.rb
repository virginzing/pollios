class VoterFordeleteSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :member, :poll_id, :choice_id, :vote_at

  def vote_at
    object.created_at
  end

  def member
    MemberForDeleteSerializer.new(object.member).as_json()
  end


end
