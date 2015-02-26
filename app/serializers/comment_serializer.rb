class CommentSerializer < ActiveModel::Serializer
  self.root false
  
  attributes :id, :member_id, :fullname, :avatar, :message, :created_at, :mentionable_list

  def created_at
    object.created_at.to_i
  end

  def member_id
    object.member_id
  end

  def fullname
    object.member_fullname
  end

  def mentionable_list
    if object.mentions.present?
      object.mentions.collect{|e| { id: e.mentionable_id, name: e.mentionable_name }}
    else
      ""
    end
  end

  def avatar
    object.member_avatar.to_s.present? ? "http://res.cloudinary.com/code-app/image/upload/c_fill,h_180,w_180,#{Cloudinary::QualityImage::SIZE}/" + object.member_avatar.to_s : ""
  end

end
