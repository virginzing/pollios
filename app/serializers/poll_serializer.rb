class PollSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :title, :poll_within

  def id
    object.id
  end

  def title
    object.title
  end

  def poll_within
    object.poll_is_where
  end


end
