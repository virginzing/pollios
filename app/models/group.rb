class Group < ActiveRecord::Base
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :member
  has_many :polls
  
  mount_uploader :photo_group, PhotoGroupUploader

  def self.check_member_in_group(friend_id, group_id)
    return friend_id - find(group_id).group_members.map(&:member_id) if find(group_id).present?
  end

  def cached_created_by
    Rails.cache.fetch([ self, 'created_by' ]) do
      group_members.where(is_master: true).first.member.username
    end
  end

end
