class Group < ActiveRecord::Base
  include GroupHelper

  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :member

  has_many :group_members_active, -> { where("group_members.active = 't'") },through: :group_members, source: :member
  
  has_many :poll_groups, dependent: :destroy
  has_many :polls, through: :poll_groups, source: :poll

  has_many :polls_active, -> { where("polls.expire_date > ? AND polls.status_poll != -1", Time.zone.now) }, through: :poll_groups, source: :poll

  has_many :member_active, -> { where(active: true) }, class_name: "GroupMember"
  has_many :get_member_active, through: :member_active, source: :member

  has_many :member_inactive, -> { where(active: false) }, class_name: "GroupMember"
  has_many :get_member_inactive, through: :member_inactive, source: :member

  has_many :open_notification, -> { where(notification: true, active: true) }, class_name: "GroupMember"
  has_many :get_member_open_notification, through: :open_notification, source: :member

  has_many :invite_codes, dependent: :destroy

  has_one :group_company, dependent: :destroy
  
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

      JoinGroupWorker.perform_async(member_id, group_id)

      Rails.cache.delete([member_id, 'group_active'])

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
    set_privacy = group[:public] || true

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
      
      add_friend_to_group(@group.id, member, friend_id) if friend_id
    end
    @group
  end

  def self.add_friend_to_group(group_id, member, friend)
    member_id = member.id
    
    list_friend = friend.split(",").collect {|e| e.to_i }
    check_valid_friend = friend_exist_group(list_friend, group_id)
    find_master_of_group = GroupMember.where("group_id = ? AND is_master = ?", group_id, true).first
    master_of_group = find_master_of_group.present? ? find_master_of_group.member_id : false

    if find(group_id).authorize_invite.everyone? || (master_of_group == member_id)
      if check_valid_friend.count > 0
        Member.where(id: check_valid_friend).each do |friend|
          @group_member = GroupMember.create(member_id: friend.id, group_id: group_id, is_master: false, invite_id: member_id, active: friend.group_active)
        end
        InviteFriendWorker.perform_async(member_id, list_friend, group_id)
        @group_member.group
      end
    end
  end

  def self.friend_exist_group(list_friend, group_id)
    return list_friend - find(group_id).group_members.map(&:member_id) if find(group_id).present?
  end


  def self.add_poll(member, poll, group_id)
    list_group = group_id.split(",")
    Group.transaction do
      where(id: list_group).each do |group|
        if group.poll_groups.create!(poll_id: poll.id, member_id: member.id)
          group.increment!(:poll_count)
          GroupNotificationWorker.perform_in(5.seconds, member.id, group.id, poll.id) if Rails.env.production?
        end
      end
    end
  end
  
  def kick_member_out_group(kicker, friend_id)
    begin
      raise ExceptionHandler::Forbidden, "You're not an admin of the group" unless group_members.find_by(member_id: kicker.id).is_master
      if find_member_in_group = group_members.find_by(member_id: friend_id)
        find_member_in_group.destroy
      else
        raise ExceptionHandler::NotFound, "Not found this member in group"
      end

      Rails.cache.delete([friend_id, 'group_active'])
      self
    end
  end

  def promote_admin(promoter, friend_id, admin_status = true)
    begin
      raise ExceptionHandler::Forbidden, "You're not an admin of the group" unless group_members.find_by(member_id: promoter.id).is_master
      if find_member_in_group = group_members.find_by(member_id: friend_id)
        find_member_in_group.update!(is_master: admin_status)
      else
        raise ExceptionHandler::NotFound, "Not found this member in group"
      end

      Rails.cache.delete([friend_id, 'group_active'])
      self
    end
  end

  def get_description
    description.present? ? description : ""
  end

  def get_poll_not_vote_count
    poll_groups_ids = polls_active.map(&:id)
    my_vote_poll_ids = Member.voted_polls.collect{|e| e["poll_id"] } 
    # puts "#{poll_groups_ids}"
    # puts "#{my_vote_poll_ids}"
    return (poll_groups_ids - my_vote_poll_ids).count
  end

  def get_member_count
    group_members_active.map(&:id).count
  end

  def get_all_member_count
    group_members.map(&:member_id).uniq.count
  end

  def get_all_poll_count
    poll_groups.map(&:poll_id).uniq.count
  end

  def as_json options={}
   {
      id: id,
      name: name,
      photo: get_photo_group,
      public: public,
      description: get_description,
      leave_group: leave_group
   }
  end

end
