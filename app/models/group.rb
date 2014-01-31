class Group < ActiveRecord::Base
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :member
  
  has_many :poll_groups, dependent: :destroy
  has_many :polls, through: :poll_groups, source: :poll

  has_many :member_active, -> { where(active: true) }, class_name: "GroupMember"
  has_many :get_member_active, through: :member_active, source: :member

  has_many :member_inactive, -> { where(active: false) }, class_name: "GroupMember"
  has_many :get_member_inactive, through: :member_inactive, source: :member

  validates :name, presence: true
  mount_uploader :photo_group, PhotoGroupUploader


  def cached_created_by
    Rails.cache.fetch([ self, 'created_by' ]) do
      group_members.where(is_master: true).first.member.username
    end
  end

  def self.accept_group(group)
    group_id = group[:group_id]
    member_id = group[:member_id]

    find_group_member = GroupMember.where(member_id: member_id, group_id: group_id).first
    if find_group_member
      find_group_member.update_attributes!(active: true)
    end
  end


  def self.build_group(group)
    member_id = group[:member_id]
    name = group[:name]
    friend_id = group[:friend_id]

    @group = create(name: name)

    if @group.valid?
      @group.group_members.create(member_id: member_id, is_master: true, active: true)
      add_friend_to_group(@group.id, {:member_id => member_id, :friend_id => friend_id.split(",")} ) if friend_id
    end
    @group
  end

  def self.add_friend_to_group(group, option = {})
    member_id   = option[:member_id] || group[:member_id]
    list_friend = option[:friend_id] || group[:friend_id].split(",")
    group_id = group || group[:group_id]

    check_valid_friend = friend_exist_group(list_friend, group_id)

    if check_valid_friend.count > 0
      Member.where(id: check_valid_friend).each do |friend|
        @group_member = GroupMember.create(member_id: friend.id, group_id: group_id, is_master: false, invite_id: member_id, active: friend.group_active)
      end
      @group_member.group
    end
  end

  def self.friend_exist_group(list_friend, group_id)
    return list_friend - find(group_id).group_members.map(&:member_id) if find(group_id).present?
  end



  def self.add_poll(poll_id, group_id)
    list_group = group_id.split(",")
    where(id: list_group).each do |group|
      group.polls.create!(poll_id: poll_id)
    end
  end

end
