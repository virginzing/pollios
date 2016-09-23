# WARNING: NO LONGER NEEDED. Will be deleted when new Member::GroupAction is finished
# NOTE: Not all logics are correct. Some might be wrong. Don't mindlessly copy & paste.
# Rethink every single line!

class Member::GroupActionLegacy
  include Member::Private::GroupActionGuard
  include Member::Private::GroupAction

  attr_reader :member, :group

  def initialize(member, group = nil, options = {})
    @member = member
    @group = group
    @options = options
  end

  def create(group_params = {})
    @group = Group.new(
      member_id: @member.id,
      name: group_params[:name],
      group_type: :normal, # not sure about this, should generalize
      photo_group: group_params[:photo_group],
      description: group_params[:description],
      cover: group_params[:cover],
      cover_preset: group_params[:cover_preset],
      public: group_params[:public].to_b,
      admin_post_only: group_params[:admin_post_only].to_b,
      authorize_invite: :everyone,
      need_approve: group_params[:need_approve]
    )

    if @group.save!
      set_group_cover(group_params[:cover])
      set_admin_of_group
      group.create_group_company(company: @member.get_company) if @member.company.present?

      FlushCached::Member.new(@member).clear_list_groups

      invite(group_params[:friend_id])
    end

    @group
  end

  def invite(friend_ids, options = {})
    return unless friend_ids

    member_ids = friend_ids.split(',').map(&:to_i)
    member_ids_to_invite = Group::MemberList.new(@group).filter_non_members_from_list(member_ids)

    # TODO: Implement this logic.
    # unless member.company?
    #   unless group.system_group || group.public
    #     raise ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_ADMIN unless find_admin_group.include?(member_id)
    # end

    if member_ids_to_invite.size > 0
      members = Member.where(id: member_ids_to_invite)
      members.each do |friend|
        invite_member(friend)
      end

      FlushCached::Group.new(@group).clear_list_members
      InviteFriendToGroupWorker.perform_async(@member.id, member_ids_to_invite, @group.id, options) unless Rails.env.test?
    end
  end

  # TODO: Write test for this. This is not tested and therefore NOT READY
  def join(options = {})
    new_request = false
    joined = false

    if @group.need_approve
      new_request, joined = request_joining_group()
    else
      new_request, joined = joining_group()
    end

    return new_request, joined
  end

  private

  def members_not_in_group(member_list)
    member_list - @group.group_members.map(&:member_id)
  end

    # helper functions for #create
    def set_group_cover(cover)
      cover_group_url = ImageUrl.new(cover)
      if cover && cover_group_url.from_image_url?
        @group.update_column(:cover_preset, "0")
        @group.update_column(:cover, cover_group_url.split_cloudinary_url)
      end
    end

    def set_admin_of_group()
      @group.group_members.create(member_id: @member.id, is_master: true, active: true)
    end

    def invite_member(invitee)
      GroupMember.create(member_id: invitee.id, group_id: @group.id, is_master: false, invite_id: @member.id, active: invitee.group_active)
      FlushCached::Member.new(invitee).clear_list_groups
    end

    # helper function for joining/request
    def joining_group()
      new_request = true
      joined = true

      group_member_action = Group::MemberAction.new(@group)
      group_member_action.accept(@member)

      return new_request, joined
    end

    def request_joining_group()
      new_request = true
      joined = false

      is_member_active_in_group = Group::MemberInquiry.new(@group).active?(member)

      if is_member_active_in_group
        raise ExceptionHandler::UnprocessableEntity, "You have already joined #{group.name}"
      end

      if GroupMember.have_request_group?(@group, @member)
        group_member_action = Group::MemberAction.new(@group)
        group_member_action.accept(@member)
        joined = true
      else
        request_groups = @group.request_groups.where(member_id: @member.id).first_or_create do |each_group|
          each_group.member_id = @member.id
          each_group.group_id = @group.id
          each_group.save!
          new_request = true
          @member.flush_cache_ask_join_groups
          RequestGroupWorker.perform_async(@member.id, @group.id) unless Rails.env.test?
        end
      end

      return new_request, joined
    end
  end
