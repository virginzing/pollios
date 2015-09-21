class GroupDetailSerializer < ActiveModel::Serializer
  self.root false

  attributes :id, :name, :description, :member_count

  def member_count
    object.get_member_count
  end
end