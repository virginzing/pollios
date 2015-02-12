class GroupSerializer < ActiveModel::Serializer
  self.root false

  attributes :id, :name, :photo, :member_count, :poll_count

  def photo
    object.photo_group.url(:thumbnail)
  end
  
end