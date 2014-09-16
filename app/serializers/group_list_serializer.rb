class GroupListSerializer < ActiveModel::Serializer
  self.root false

  attributes :id, :text

  def text
    object.name
  end
end