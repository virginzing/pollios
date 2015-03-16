class LoadPollSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :desc

  def id
    object.id
  end

  def desc
    object.title
  end
  
  
end