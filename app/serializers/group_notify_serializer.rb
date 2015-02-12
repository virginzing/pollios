class GroupNotifySerializer < ActiveModel::Serializer

  self.root false

  attributes :id, :name, :cover, :description

  def cover
    object.get_cover_group
  end

  def description
    object.get_description
  end

end