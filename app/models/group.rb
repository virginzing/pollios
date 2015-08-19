# == Schema Information
#
# Table name: groups
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  public           :boolean          default(FALSE)
#  photo_group      :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  authorize_invite :integer
#  description      :text
#  leave_group      :boolean          default(TRUE)
#  group_type       :integer
#  cover            :string(255)
#  admin_post_only  :boolean          default(FALSE)
#  need_approve     :boolean          default(TRUE)
#  public_id        :string(255)
#  visible          :boolean          default(TRUE)
#  system_group     :boolean          default(FALSE)
#  virtual_group    :boolean          default(FALSE)
#  member_id        :integer
#  cover_preset     :string(255)      default("0")
#  exclusive        :boolean          default(FALSE)
#  deleted_at       :datetime
#  opened           :boolean          default(FALSE)
#

class Group < ActiveRecord::Base
  acts_as_paranoid
  # extend FriendlyId
  resourcify
  include GroupHelper

  has_many :group_members
  has_many :members, through: :group_members, source: :member

  has_many :group_members_active, -> { where("group_members.active = 't'") }, through: :group_members, source: :member

  has_many :get_admin_group, -> { where("group_members.active = 't' AND group_members.is_master = 't'") },through: :group_members, source: :member

  has_many :poll_groups
  has_many :polls, through: :poll_groups, source: :poll

  has_many :polls_active, -> { where("polls.expire_date > ? AND polls.status_poll != -1", Time.zone.now) }, through: :poll_groups, source: :poll

  has_many :member_active, -> { where(active: true) }, class_name: "GroupMember"
  has_many :get_member_active, through: :member_active, source: :member

  has_many :member_inactive, -> { where(active: false) }, class_name: 'GroupMember'
  has_many :get_member_inactive, through: :member_inactive, source: :member

  has_many :open_notification, -> { where(notification: true, active: true) }, class_name: "GroupMember"
  has_many :get_member_open_notification, through: :open_notification, source: :member

  has_many :invite_codes

  has_one :group_company

  has_many :group_surveyors
  has_many :surveyor, through: :group_surveyors, source: :member

  has_many :request_groups, -> { where(accepted: false) }
  has_many :members_request, through: :request_groups, source: :member

  belongs_to :member

  validates :name, presence: true

  validates :public_id , :uniqueness => { message: "Public ID has already been taken." }, format: { with: /\A[a-zA-Z0-9_.]+\z/i, message: "Public ID only allows letters." } ,:allow_blank => true , on: :update

  mount_uploader :photo_group, PhotoGroupUploader
  mount_uploader :cover, PhotoGroupUploader

  after_commit :flush_cache

  after_create :set_public_id
  before_create :set_cover_preset

  default_scope { with_deleted.where(visible: true) }

  scope :without_deleted, -> { where(deleted_at: nil) }
  scope :only_public, -> { where(public: true) }

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) do
      @group = Group.find_by(id: id)
      raise ExceptionHandler::NotFound, ExceptionHandler::Message::Group::NOT_FOUND unless @group.present?
      @group
    end
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def set_cover_preset
    unless self.cover.present?
      if self.cover_preset.present?
        self.cover_preset = Group.random_cover_preset unless self.cover_preset != "0"
      else
        self.cover_preset = Group.random_cover_preset
      end
    else
      self.cover_preset = "0"
    end
  end

  def set_public_id
    exist_count = 0
    begin
      join_name = name.scan(/[a-zA-Z0-9_.]+/).join
      public_id = join_name[0..19]

      if exist_count > 0
        public_id = join_name[0..9] + Time.now.to_i.to_s
      end

      exist_count = exist_count + 1
    end while Group.exists?(public_id: public_id)

    update!(public_id: public_id)
  end

  def get_photo_group
    photo_group.present? ? resize_photo_group(photo_group.url) : ""
  end

  def resize_photo_group(photo_group_url)
    photo_group_url.split("upload").insert(1, "upload/c_fill,h_200,w_200," + Cloudinary::QualityImage::SIZE).sum
  end

  def get_cover_group
    cover.present? ? resize_cover_group(cover.url) : ""
  end

  def resize_cover_group(cover_url)
    cover_url.split("upload").insert(1, "upload/c_fit,w_640," + Cloudinary::QualityImage::SIZE).sum
  end

  def get_public_id
    public_id.present? ? public_id : ""
  end

  def self.accept_group(member, group)
    group_id = group[:id]
    member_id = group[:member_id]

    find_group_member = GroupMember.where(member_id: member_id, group_id: group_id).first

    raise ExceptionHandler::UnprocessableEntity, "This request had already cancelled." if find_group_member.nil?

    if find_group_member
      @group = find_group_member.group
      @member = member

      find_group_member.update_attributes!(active: true)

      if @group.company? && !@group.system_group
        CompanyMember.add_member_to_company(@member, @group.get_company)
        Activity.create_activity_group(@member, @group, 'Join')
      end

      if @group.member.company?
        Company::FollowOwnerGroup.new(@member, @group.member.id).follow!
      end

      clear_request_group(@member, @member)

      Company::TrackActivityFeedGroup.new(@member, @group, "join").tracking
      JoinGroupWorker.perform_async(member_id, group_id) unless Rails.env.test?

      FlushCached::Group.new(@group).clear_list_members
      FlushCached::Member.new(@member).clear_list_groups
    end
    @group
  end

  def self.deny_request_join_group_my_self(member, group) ## cancel of myself
    find_group_member = GroupMember.where(group_id: group.id, member_id: member.id).first

    raise ExceptionHandler::UnprocessableEntity, "This request had already cancelled." unless find_group_member.present?

    if find_group_member
      find_group_member.destroy

      if find_group_member.group.company?
        member.remove_role :group_admin, find_group_member.group
      end
    end

    FlushCached::Member.new(member).clear_list_groups
    FlushCached::Group.new(group).clear_list_members

    group
  end

  def self.cancel_group(member, friend, group) ## cancel to another people
    raise ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_ADMIN unless Group::ListMember.new(group).is_admin?(member)
    raise ExceptionHandler::UnprocessableEntity, "#{friend.get_name} had already accepted your request." if Group::ListMember.new(group).active.map(&:id).include?(friend.id)

    find_group_member = GroupMember.where(group_id: group.id, member_id: friend.id).first

    raise ExceptionHandler::UnprocessableEntity, "This request had already cancelled." unless find_group_member.present?

    if find_group_member
      find_group_member.destroy
      NotifyLog.check_update_cancel_invite_friend_to_group_deleted(member, friend, group)

      if find_group_member.group.company?
        friend.remove_role :group_admin, find_group_member.group
      end
    end

    FlushCached::Member.new(friend).clear_list_groups
    FlushCached::Group.new(group).clear_list_members

    group
  end

  def self.leave_group(member, group)
    find_group_member = GroupMember.where(group_id: group.id, member_id: member.id).first

    if find_group_member
      find_group_member.destroy
      LeaveGroupLog.leave_group_log(member, group)

      if find_group_member.group.company?
        member.remove_role :group_admin, find_group_member.group
      end
    end

    FlushCached::Member.new(member).clear_list_groups
    FlushCached::Group.new(group).clear_list_members

    group
  end

  def self.accept_request_group(member, friend, group)
    GroupMember.transaction do
      begin
        @friend = friend
        @member = member
        @group = group

        if @group.need_approve
          raise ExceptionHandler::UnprocessableEntity, "#{@friend.get_name} has cancelled to request this group." unless @friend.cached_ask_join_groups.map(&:id).include?(@group.id)
        end

        raise ExceptionHandler::UnprocessableEntity, "#{@friend.get_name} had approved." if Member::ListGroup.new(@friend).active.map(&:id).include?(@group.id)

        find_member_in_group = @group.group_members.find_by(member_id: @friend.id)

        if find_member_in_group.present?
          find_member_in_group.update!(active: true)
        else
          GroupMember.create!(member_id: @friend.id, active: true, is_master: false, group_id: @group.id)
        end

        if @group.company? && !@group.system_group
          CompanyMember.add_member_to_company(@friend, @group.get_company)
        end

        if @group.member.company?
          Company::FollowOwnerGroup.new(@friend, @group.member.id).follow!
        end

        if @group.need_approve
          ApproveRequestGroupWorker.perform_async(@member.id, @friend.id, @group.id) unless Rails.env.test?
        end

        Company::TrackActivityFeedGroup.new(@friend, @group, "join").tracking

        FlushCached::Group.new(@group).clear_list_members

        clear_request_group(@member, @friend)

        JoinGroupWorker.perform_async(@friend.id, @group.id) unless Rails.env.test?

        Activity.create_activity_group(@friend, @group, 'Join')

        FlushCached::Member.new(@friend).clear_list_groups

        @friend.flush_cache_ask_join_groups

        @group
      end
    end
  end

  def self.cancel_ask_join_group(member, friend_id = nil, group)
    if friend_id.nil? ## cancel request myself
      raise ExceptionHandler::UnprocessableEntity, "Your request had approved by administrator." if Group::ListMember.new(group).active.map(&:id).include?(member.id)

      find_current_ask_group = group.request_groups.find_by(member_id: member.id)
      raise ExceptionHandler::UnprocessableEntity,  "There isn't your request to this group." unless find_current_ask_group.present?

      if find_current_ask_group.present?
        find_current_ask_group.destroy
        NotifyLog.check_update_cancel_request_group_deleted(member, group)

        member.flush_cache_ask_join_groups
        group
      end
    else
      find_friend = Member.cached_find(friend_id)

      find_current_ask_group = group.request_groups.find_by(member_id: find_friend.id)

      raise ExceptionHandler::UnprocessableEntity, "User had cancelled." unless find_current_ask_group.present?

      if find_current_ask_group.present?
        find_current_ask_group.destroy
        find_friend.flush_cache_ask_join_groups
        group
      end
    end
  end

  def self.clear_request_group(member, friend)
    find_request_group = @group.request_groups.find_by(member_id: friend.id, accepted: false)
    find_request_group.update!(accepted: true, accepter_id: member.id) if find_request_group.present?
  end

  def self.build_group(member, group_params)
    member_id = group_params[:member_id]
    photo_group = group_params[:photo_group]
    description = group_params[:description]
    cover = group_params[:cover]
    cover_preset = group_params[:cover_preset]
    set_privacy = group_params[:public].to_b
    set_admin_post_only = group_params[:admin_post_only].to_b
    name = group_params[:name]
    friend_id = group_params[:friend_id]

    init_cover_group = ImageUrl.new(cover)

    @group = new(member_id: member.id, name: name, photo_group: photo_group, authorize_invite: :everyone, description: description, public: set_privacy, cover: cover, cover_preset: cover_preset, group_type: :normal, admin_post_only: set_admin_post_only)

    if @group.save!

      if cover && init_cover_group.from_image_url?
        @group.update_column(:cover_preset, "0")
        @group.update_column(:cover, init_cover_group.split_cloudinary_url)
      end

      @group.create_group_company(company: member.get_company) if member.company?
      @group.group_members.create(member_id: member_id, is_master: true, active: true)

      Company::TrackActivityFeedGroup.new(member, @group, "join").tracking
      GroupStats.create_group_stats(@group)

      if @group.public
        Activity.create_activity_group(member, @group, 'Create')
      end

      FlushCached::Member.new(member).clear_list_groups

      add_friend_to_group(@group, member, friend_id) if friend_id
    end

    @group
    rescue ActiveRecord::RecordInvalid => e
      fail ExceptionHandler::UnprocessableEntity, e.record.errors.full_messages.join(", ")
  end

  def self.random_cover_preset
    rand(1..26).to_s
  end

  def self.add_friend_to_group(group, member, friend_id, custom_data = {})
    group_id = group.id
    member_id = member.id

    list_friend = friend_id.split(",").collect {|e| e.to_i }
    list_invite_friend_ids = friend_exist_group(list_friend, group)
    find_admin_group = group.get_admin_group.map(&:id)

    unless member.company?
      unless group.system_group || group.public
        raise ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_ADMIN unless find_admin_group.include?(member_id)
      end
    end

    if list_invite_friend_ids.size > 0
      Member.where(id: list_invite_friend_ids).each do |friend|
        GroupMember.create(member_id: friend.id, group_id: group_id, is_master: false, invite_id: member_id, active: friend.group_active)
        FlushCached::Member.new(friend).clear_list_groups
      end

      FlushCached::Group.new(group).clear_list_members
      InviteFriendToGroupWorker.perform_async(member_id, list_invite_friend_ids, group_id, custom_data) unless Rails.env.test?
    end

    group
  end

  def self.friend_exist_group(list_friend, group)
    return list_friend - group.group_members.map(&:member_id) if group.present?
  end


  def self.add_poll(member, poll, group_id)
    list_group = group_id
    Group.transaction do
      where(id: list_group).each do |group|
        group.poll_groups.create!(poll_id: poll.id, member_id: member.id)
      end
    end
  end

  def self.clear_request_member(group, member)
    find_member = group.group_members.find_by(member_id: member.id)
    find_member.destroy if find_member.present?
  end

  def kick_member_out_group(kicker, friend_id)
    begin

      raise ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_ADMIN unless Group::ListMember.new(self).is_admin?(kicker)

      member = Member.cached_find(friend_id)

      if find_member_in_group = group_members.find_by(member_id: friend_id)
        find_member_in_group.destroy

        GroupActionLog.create_log(self, kicker, member, "kick")

        member.remove_role :group_admin, find_member_in_group.group

        FlushCached::Group.new(self).clear_list_members
      else
        raise ExceptionHandler::NotFound, ExceptionHandler::Message::Group::MEMBER_NOT_IN_GROUP
      end

      FlushCached::Member.new(member).clear_list_groups

      self
    end
  end

  def promote_admin(promoter, friend_id, admin_status = true)
    begin
      member = Member.cached_find(friend_id)

      fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_ADMIN unless Group::ListMember.new(self).is_admin?(promoter)
      if admin_status
        fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::ADMIN if Group::ListMember.new(self).is_admin?(member)
      end

      if find_member_in_group = group_members.find_by(member_id: friend_id)
        find_group = find_member_in_group.group

        if find_group.company? ## Is it group of company?
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
            fail ExceptionHandler::UnprocessableEntity, "You have already admin of #{find_exist_role_member.name} Company."
          end

        else
          find_member_in_group.update!(is_master: admin_status)

          unless Rails.env.test?
            if admin_status
              PromoteAdminWorker.perform_async(promoter.id, friend_id, find_group.id)
            end
          end
        end

        if admin_status
          GroupActionLog.create_log(self, promoter, member, "promote_admin")
        else
          GroupActionLog.create_log(self, promoter, member, "degrade_admin")
        end

      else
        fail ExceptionHandler::NotFound, ExceptionHandler::Message::Group::MEMBER_NOT_IN_GROUP
      end

      FlushCached::Group.new(self).clear_list_members
      FlushCached::Member.new(member).clear_list_groups
      self
    end
  end

  def get_description
    description.present? ? description : ""
  end

  def remove_old_cover
    remove_cover!
    save!
  end

  def get_poll_not_vote_count
    poll_groups_ids = Poll.available.joins(:groups).where("poll_groups.group_id = #{self.id}").uniq.map(&:id)
    my_vote_poll_ids = Member.voted_polls.collect{|e| e["poll_id"] }
    return (poll_groups_ids - my_vote_poll_ids).size
  end

  def add_user_to_group(list_of_users)
    list_of_users.each do |member|
      group_members.create!(member: member, is_master: false, active: true)
      Company::TrackActivityFeedGroup.new(member, self, "join").tracking
      FlushCached::Member.new(member).clear_list_groups
    end
  end

  def get_member_count
    Group::ListMember.new(self).active.to_a.size
  end

  def get_all_member_count
    group_members.map(&:member_id).uniq.size
  end

  def get_all_poll_count
    poll_groups.without_deleted.map(&:poll_id).uniq.size
  end

  def get_company
    group_company.company
  end

  def check_as_admin?(current_member)
    get_admin_group.map(&:id).include?(current_member.id)
  end

  def get_admin_post_only
    admin_post_only.present? ? true : false
  end

  def as_json options={}
    {
      id: id,
      name: name,
      cover: get_cover_group,
      public: public,
      description: get_description,
      leave_group: leave_group,
      created_at: created_at.to_i,
      admin_post_only: get_admin_post_only,
      need_approve: need_approve,
      public_id: get_public_id,
      group_type: group_type_text.downcase
    }
  end

  #### deprecated ####

  # def self.cached_member_active(group_id)
  #   Rails.cache.fetch([ 'group', group_id, 'member_active']) do
  #     Group.find(group_id).get_member_active.to_a.map(&:id)
  #   end
  # end

  # def self.flush_cached_member_active(group_id)
  #   Rails.cache.delete([ 'group', group_id, 'member_active' ])
  # end

  # def company?
  #   group_company.present?
  # end

  # def is_company?
  #   self.group_type == "company"
  # end

  # def set_notification(member_id)
  #   group_member = group_members.where("member_id = ?", member_id)
  # end
end
