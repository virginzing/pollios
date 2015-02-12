class GroupNotifySerializer < ActiveModel::Serializer

  self.root false

  attributes :id, :name, :photo, :description

  def photo
    object.get_photo_group
  end

  def description
    object.get_description
  end

end