class ChoiceSerializer < ActiveModel::Serializer
  self.root false
  
  attributes :choice_id, :answer, :vote

  def choice_id
    object.id
  end

  def answer
    object.answer
  end

  def vote
    object.vote
  end

end