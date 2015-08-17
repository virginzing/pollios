# == Schema Information
#
# Table name: suggests
#
#  id             :integer          not null, primary key
#  poll_series_id :integer
#  member_id      :integer
#  message        :text
#  created_at     :datetime
#  updated_at     :datetime
#

class SuggestSerializer < ActiveModel::Serializer
  self.root false
  
  attributes :id, :member_id, :fullname, :avatar, :message, :created_at

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
    object.member_avatar.to_s.present? ? "http://res.cloudinary.com/pollios/image/upload/c_fill,h_180,w_180,#{Cloudinary::QualityImage::SIZE}/" + object.member_avatar.to_s : ""
  end

end

