class Group < ActiveRecord::Base
  resourcify
  include GroupHelper

  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :member

  has_many :group_members_active, -> { where("group_members.active = 't'") },through: :group_members, source: :member

  has_many :get_admin_group, -> { where("group_members.active = 't' AND is_master = 't'") },through: :group_members, source: :member

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

  has_many :group_surveyors, dependent: :destroy
  has_many :surveyor, through: :group_surveyors, source: :member

  has_many :request_groups, -> { where(accepted: false) } , dependent: :destroy
  has_many :members_request, through: :request_groups, source: :member

  validates :name, presence: true

  mount_uploader :photo_group, PhotoGroupUploader
  mount_uploader :cover, PhotoGroupUploader

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

  def get_cover_group
    cover.present? ? cover.url(:cover) : ""
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
      @member = member

      find_group_member.group.increment!(:member_count)
      find_group_member.update_attributes!(active: true)

      JoinGroupWorker.perform_async(member_id, group_id)

      Rails.cache.delete([member_id, 'group_active'])

      if @group
        Activity.create_activity_group(member, @group, 'Join')
      end
    end
    @group
  end

  def self.accept_request_group(member, friend, group)
    GroupMember.transaction do
      begin
        @friend = friend
        @member = member
        @group = group

        if @group.group_members.create!(member_id: @friend.id, active: true, is_master: false)
          @group.increment!(:member_count)
          clear_request_group
          JoinGroupWorker.perform_async(@friend.id, @group.id)
          @friend.flush_cache_my_group
          @friend.flush_cache_ask_join_groups
          Activity.create_activity_group(@friend, @group, 'Join')
        end
        @group
      end
    end
  end

  def self.cancel_ask_join_group(member, group)
    find_current_ask_group = group.request_groups.find_by(member_id: member.id)
    if find_current_ask_group.present?
      find_current_ask_group.destroy
      member.flush_cache_ask_join_groups
      group
    end
  end

  def self.clear_request_group
    find_request_group = @group.request_groups.find_by(member_id: @friend.id, accepted: false)
    find_request_group.update!(accepted: true, accepter_id: @member.id) if find_request_group.present?
  end

  def self.build_group(member, group)
    member_id = group[:member_id]
    photo_group = group[:photo_group]
    description = group[:description]
    cover = group[:cover]
    set_privacy = group[:public] || true

    name = group[:name]
    friend_id = group[:friend_id]

    @group = create(name: name, photo_group: photo_group, member_count: 1, authorize_invite: :everyone, description: description, public: set_privacy, cover: cover)

    if @group.valid?
      @group.group_members.create(member_id: member_id, is_master: true, active: true)

      GroupStats.create_group_stats(@group)

      if @group.public
        Activity.create_activity_group(member, @group, 'Create')
      end

      Rails.cache.delete([member_id, 'group_active'])

      add_friend_to_group(@group, member, friend_id) if friend_id
    end
    @group
  end

  def self.add_friend_to_group(group, member, friend)
    group_id = group.id
    member_id = member.id

    list_friend = friend.split(",").collect {|e| e.to_i }
    check_valid_friend = friend_exist_group(list_friend, group)
    # find_master_of_group = GroupMember.where("group_id = ? AND is_master = ?", group_id, true).first
    find_admin_group = group.get_admin_group.map(&:id)

    if find_admin_group.include?(member_id)
      if check_valid_friend.count > 0
        Member.where(id: check_valid_friend).each do |friend|
          @group_member = GroupMember.create(member_id: friend.id, group_id: group_id, is_master: false, invite_id: member_id, active: friend.group_active)
        end
        InviteFriendWorker.perform_async(member_id, list_friend, group_id)
        @group_member.group
      end
    else
      raise ExceptionHandler::Forbidden, "You are not admin of group"
    end
  end

  def self.friend_exist_group(list_friend, group)
    return list_friend - group.group_members.map(&:member_id) if group.present?
  end


  def self.add_poll(member, poll, group_id)
    list_group = group_id
    Group.transaction do
      where(id: list_group).each do |group|
        if group.poll_groups.create!(poll_id: poll.id, member_id: member.id)
          group.increment!(:poll_count)
          GroupNotificationWorker.perform_in(5.seconds, member.id, group.id, poll.id)
        end
      end
    end
  end

  def kick_member_out_group(kicker, friend_id)
    begin
      raise ExceptionHandler::Forbidden, "You're not an admin of the group" unless group_members.find_by(member_id: kicker.id).is_master
      if find_member_in_group = group_members.find_by(member_id: friend_id)
        find_member_in_group.destroy
        Member.find(friend_id).remove_role :group_admin, find_member_in_group.group
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
        find_group = find_member_in_group.group

        if find_group.is_company? ## Is it group of company?
          find_member = find_member_in_group.member

          find_role_member = find_member.roles.first

          if find_role_member.present?
            find_exist_role_member = find_role_member.resource.get_company
          end

          if find_role_member.nil? || (find_exist_role_member.id == find_group.get_company.id)
            find_member_in_group.update!(is_master: admin_status)

            if admin_status
              find_member.add_role :group_admin, find_group
            else
              find_member.remove_role :group_admin, find_group
            end
          else
            raise ExceptionHandler::Forbidden, "You have already exist admin of #{find_exist_role_member.name} Company"
          end

        else
          find_member_in_group.update!(is_master: admin_status)
        end

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
    poll_groups_ids = Poll.available.joins(:groups).where("poll_groups.group_id = #{self.id}").uniq.map(&:id)
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

  def is_company?
    group_company.present?
  end

  def get_company
    group_company.company
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
