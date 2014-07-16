class PollSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :creator, :title, :poll_within

  def id
    object.id
  end

  def creator
    {
      member_id: object.member.id,
      name: object.member.fullname
    }
  end

  def title
    object.title
  end

  def poll_within
    object.poll_is_where
  end


end
