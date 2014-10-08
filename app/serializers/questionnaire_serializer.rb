class QuestionnaireSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :creator, :title, :poll_within, :series

  def id
    object.polls.select{|poll| poll if poll.order_poll }.min.id
  end

  def creator
    {
      member_id: object.member.id,
      name: object.member.fullname
    }
  end

  def title
    object.description
  end

  def poll_within
    object.poll_is_where
  end

  def series
    true
  end
  
end