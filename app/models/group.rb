class Group < ActiveRecord::Base
  include GroupHelper
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :member
  
  has_many :poll_groups, dependent: :destroy
  has_many :polls, through: :poll_groups, source: :poll

  has_many :member_active, -> { where(active: true) }, class_name: "GroupMember"
  has_many :get_member_active, through: :member_active, source: :member

  has_many :member_inactive, -> { where(active: false) }, class_name: "GroupMember"
  has_many :get_member_inactive, through: :member_inactive, source: :member

  has_many :open_notification, -> { where(notification: true, active: true) }, class_name: "GroupMember"
  has_many :get_member_open_notification, through: :open_notification, source: :member

  has_many :invite_codes, dependent: :destroy
  
  validates :name, presence: true

  mount_uploader :photo_group, PhotoGroupUploader


  def cached_created_by
    Rails.cache.fetch([ self, 'created_by' ]) do
      group_members.where(is_master: true).first.member.fullname
    end
  end

  def self.cached_find(id)
    Rails.cache.fetch([ name, id]) { find(id) }
  end

  def get_photo_group
    photo_group.present? ? photo_group.url(:thumbnail) : ""
  end

  def set_notification(member_id)
    group_member = group_members.where("member_id = ?", member_id)
  end

  def self.accept_group(member, group)
    group_id = group[:id]
    member_id = group[:member_id]

    find_group_member = GroupMember.where(member_id: member_id, group_id: group_id).first
    if find_group_member
      @group = find_group_member.group

      find_group_member.group.increment!(:member_count)
      find_group_member.update_attributes!(active: true)

      Rails.cache.delete([member_id, 'group_active'])
      # Rails.cache.delete([member_id, 'group_count'])

      if @group.public
        Activity.create_activity_group(member, @group, 'Join')
      end
    end
    @group
  end


  def self.build_group(member, group)
    member_id = group[:member_id]
    photo_group = group[:photo_group]
    description = group[:description]
    set_privacy = group[:public] || false

    name = group[:name]
    friend_id = group[:friend_id]

    @group = create(name: name, photo_group: photo_group, member_count: 1, authorize_invite: :everyone, description: description, public: set_privacy)

    if @group.valid?
      @group.group_members.create(member_id: member_id, is_master: true, active: true)

      GroupStats.create_group_stats(@group)

      if @group.public
        Activity.create_activity_group(member, @group, 'Join')
      end
      
      Rails.cache.delete([member_id, 'group_active'])
      
      add_friend_to_group(@group.id, member_id, friend_id) if friend_id
    end
    @group
  end

  def self.add_friend_to_group(group_id, member_id, friend)
    list_friend = friend.split(",").collect {|e| e.to_i }
    check_valid_friend = friend_exist_group(list_friend, group_id)
    find_master_of_group = GroupMember.where("group_id = ? AND is_master = ?", group_id, true).first
    master_of_group = find_master_of_group.present? ? find_master_of_group.member_id : false

    if find(group_id).authorize_invite.everyone? || (master_of_group == member_id)
      if check_valid_friend.count > 0
        Member.where(id: check_valid_friend).each do |friend|
          @group_member = GroupMember.create(member_id: friend.id, group_id: group_id, is_master: false, invite_id: member_id, active: friend.group_active)
        end
        InviteFriendWorker.new.perform(member_id, list_friend, @group_member.group)
        @group_member.group
      end
    end
  end

  def self.friend_exist_group(list_friend, group_id)
    return list_friend - find(group_id).group_members.map(&:member_id) if find(group_id).present?
  end


  def self.add_poll(poll_id, group_id)
    list_group = group_id.split(",")
    where(id: list_group).each do |group|
      if group.poll_groups.create!(poll_id: poll_id)
        group.increment!(:poll_count)
      end
    end
  end

  def get_description
    description.present? ? description : ""
  end

  def as_json options={}
   {
      id: id,
      name: name,
      photo: get_photo_group,
      public: public,
      description: get_description
   }
  end

end
