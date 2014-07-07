class CommentSerializer < ActiveModel::Serializer
  self.root false
  
  attributes :id, :fullname, :avatar, :message, :created_at


  def created_at
    object.created_at.to_i
  end

end
