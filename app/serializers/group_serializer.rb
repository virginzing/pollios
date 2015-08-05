class GroupSerializer < ActiveModel::Serializer
  self.root false

  attributes :id, :name, :photo

  def photo
    object.photo_group.url(:thumbnail)
  end

end
