class MemberInfoFeedSerializer < ActiveModel::Serializer

  self.root false

  attributes :member_id, :type, :name, :avatar, :description, :key_color

  def member_id
    object.id
  end

  def type
    object.member_type_text
  end

  def name
    object.fullname
  end

  def description
    object.description || ""
  end

  def avatar
    object.avatar.present? ? resize_avatar(object.avatar.url) : ""
  end

  def key_color
    object.key_color.present? ? object.key_color : ""
  end

  def resize_avatar(avatar_url)
    avatar_url.split("upload").insert(1, "upload/c_fill,h_180,w_180,q_80").sum
  end

end
