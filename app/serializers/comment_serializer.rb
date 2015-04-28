class CommentSerializer < ActiveModel::Serializer
  self.root false
  
  attributes :id, :member_id, :fullname, :name, :avatar, :message, :created_at, :list_mentioned

  def created_at
    object.created_at.to_i
  end

  def member_id
    object.member_id
  end

  def fullname
    object.member.fullname
  end

  def name
    object.member.get_name
  end

  def list_mentioned
    if object.mentions.present?
      object.mentions.collect{|e| { member_id: e.mentionable_id, name: e.mentionable_name }}
    else
      ""
    end
  end

  def avatar
    object.member.avatar.to_s.present? ? "http://res.cloudinary.com/code-app/image/upload/c_fit,h_180,w_180,#{Cloudinary::QualityImage::SIZE}/" + object.member.avatar.to_s : ""
  end

end
