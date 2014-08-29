class CommentSerializer < ActiveModel::Serializer
  self.root false
  
  attributes :id, :fullname, :avatar, :message, :created_at

  def created_at
    object.created_at.to_i
  end

  def member_id
    object.member_id
  end

  def fullname
    object.member_fullname
  end

  def avatar
    object.member_avatar.to_s.present? ? "http://res.cloudinary.com/code-app/image/upload/c_fill,h_180,w_180/" + object.member_avatar.to_s : ""
  end

end
