class PollSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :creator_id, :creator_name, :title, :poll_within

  def id
    object.id
  end

  def creator_id
    object.member.id
  end

  def creator_name
    object.member.fullname
  end

  def title
    object.title
  end

  def poll_within
    object.poll_is_where
  end


end
