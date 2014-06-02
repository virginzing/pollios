class GroupSerializer < ActiveModel::Serializer
  self.root false

  attributes :id, :name, :photo, :member_count, :poll_count

  def photo
    object.photo_group.url(:thumbnail)
  end

  # def poll_count
  #   object.poll_groups.select("DISTINCT poll_id").count
  # end
end