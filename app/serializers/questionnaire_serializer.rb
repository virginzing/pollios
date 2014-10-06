class QuestionnaireSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :creator, :description, :questionnaire_within

  def id
    object.id
  end

  def creator
    {
      member_id: object.member.id,
      name: object.member.fullname
    }
  end

  def description
    object.description
  end

  def questionnaire_within
    object.poll_is_where
  end
end