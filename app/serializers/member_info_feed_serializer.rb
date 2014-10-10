class MemberInfoFeedSerializer < ActiveModel::Serializer

  self.root false

  attributes :member_id, :type, :name, :avatar

  def member_id
    object.id
  end

  def type
    object.member_type_text
  end

  def name
    object.fullname
  end

  def avatar
    object.avatar.present? ? resize_avatar(object.avatar.url) : ""
  end

  def resize_avatar(avatar_url)
    avatar_url.split("upload").insert(1, "upload/c_fill,h_180,w_180").sum
  end

end
