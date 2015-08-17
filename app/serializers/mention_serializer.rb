# == Schema Information
#
# Table name: mentions
#
#  id               :integer          not null, primary key
#  comment_id       :integer
#  mentioner_id     :integer
#  mentioner_name   :string(255)
#  mentionable_id   :integer
#  mentionable_name :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

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
