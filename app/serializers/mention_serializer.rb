class MentionSerializer < ActiveModel::Serializer
  self.root false

  attributes :member_id, :name, :avatar

  def member_id
    object.id
  end

  def name
    object.get_name
  end

  def avatar
    object.get_avatar
  end
  
end