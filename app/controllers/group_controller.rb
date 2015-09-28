class GroupController < ApplicationController

  before_action :authenticate_with_token!

  before_action :set_group, only: [:set_public, :members, :cancel_ask_join_group, :accept_request_group, 
                                   :request_group, :delete_group, :edit_group, :promote_admin, :kick_member, 
                                   :add_friend_to_group, :detail_group, :poll_group, :delete_poll, :notification, 
                                   :poll_available_group, :leave_group, :cancel_group]
  
  before_action :initialize_poll_feed!, only: [:poll_group, :poll_available_group]

  before_action :only_admin_of_group, only: [:edit_group, :set_public]

  expose(:watched_poll_ids) { @current_member.cached_watched.map(&:poll_id) }
  expose(:share_poll_ids) { @current_member.cached_shared_poll.map(&:poll_id) }
  expose(:hash_member_count) { @hash_member_count }

  def my_group
    init_list_group = Member::GroupList.new(@current_member)
    @group_active = init_list_group.active
    @group_inactive = init_list_group.inactive
    @hash_member_count = init_list_group.hash_member_count
  end

  def build_group
    @group =  Group.build_group(@current_member, group_params)
  end

  def edit_group
    cover = edit_group_params[:cover]
    cover_preset = edit_group_params[:cover_preset]

    @group.cover_preset = "0" if cover

    if @group.update!(edit_group_params)
      init_cover_group = ImageUrl.new(cover)

      if cover && init_cover_group.from_image_url?
        @group.remove_old_cover
        @group.update_column(:cover, init_cover_group.split_cloudinary_url)
      end

      if cover_preset.present? && @group.cover.present?
        @group.remove_old_cover
      end

      FlushCached::Group.new(@group).clear_list_group_all_member_in_group
      FlushCached::Group.new(@group).clear_list_members
    end
  end

  def add_friend_to_group
    init_list_friend ||= Member::MemberList.new(@current_member)
    @group = Group.add_friend_to_group(@group, @current_member, group_params[:friend_id])
    @is_friend = Friend.check_add_friend?(@current_member, @group.get_member_inactive, init_list_friend.check_is_friend)
  end

  def accept_group
#    GroupService.new(@current_member, Group.find(params[:id]).accept_invitation
    @group = Group.accept_group(@current_member, group_params)
  end

  def accept_request_group
    @group = Group.accept_request_group(@current_member, Member.cached_find(params[:friend_id]), @group)
  end

  def cancel_ask_join_group
    @group = Group.cancel_ask_join_group(@current_member, params[:friend_id], @group)
    render status: @group ? :created : :unprocessable_entity
  end

  def poll_group
    @init_poll = PollOfGroup.new(@current_member, @group, options_params)
    @polls = @init_poll.get_poll_of_group.paginate(page: params[:next_cursor])
    poll_helper
  end

  def members
    init_list_friend ||= Member::MemberList.new(@current_member)
    @group_members ||= Group::ListMember.new(@group)

    @member_active = @group_members.active
    @check_status_friend_of_member_active = Friend.check_add_friend?(@current_member, @member_active, init_list_friend.check_is_friend) if @member_active.present?

    @member_pending = @group_members.pending
    @check_status_friend_of_member_pending = Friend.check_add_friend?(@current_member, @member_pending, init_list_friend.check_is_friend) if @member_pending.present?

    @member_request = @group.members_request
    @check_status_friend_of_member_request = Friend.check_add_friend?(@current_member, @member_request, init_list_friend.check_is_friend) if @member_request.present?
  end

  def poll_available_group
    if derived_version == 6
      @init_poll = V6::PollOfGroup.new(@current_member, @group, options_params)
      @list_polls, @next_cursor = @init_poll.get_poll_available_of_group
      @group_by_name = @init_poll.group_by_name.slice(@group.id)
      @group_id = @group.id
    end
  end

  def poll_helper
    @poll_series, @poll_nonseries = Poll.split_poll(@polls)
    @group_by_name ||= @init_poll.group_by_name
    @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
    @total_entries = @polls.total_entries
  end

  def delete_poll
    find_poll_in_group = @group.poll_groups.where("poll_id = ?", params[:poll_id])
    respond_to do |wants|
      if find_poll_in_group.present? && params[:member_id] == find_poll_in_group.first.poll.member_id
        find_poll_in_group.first.poll.destroy
        find_poll_in_group.first.destroy
        find_poll_in_group.first.poll.member.flush_cache_about_poll
        DeletePoll.create_log(find_poll_in_group.first.poll)
        wants.json { render json: Hash["response_status" => "OK"] }
      else
        wants.json { render json: Hash["response_status" => "ERROR", "response_message" => "Unable to delete poll"] }
      end
    end
  end

  def detail_group
    @member = Member.cached_find(params[:member_id])
    @group_member ||= Group::ListMember.new(@group)
    @member_active = @group_member.join_recently
  end

  def request_group

    # TODO: Make this work!
    # member_group_action = Member::GroupAction.new(@current_member, @group)
    # @new_request, @joined = member_group_action.join()

    unless @group.need_approve
      Group.accept_request_group(@current_member, @current_member, @group)
      @new_request = true
      @joined = true
    else
      @joined = false
      member_id = params[:member_id]
      @member
      @new_req
      uest = false

      @group_members ||= Group::ListMember.new(@group)
      @member_active = @group_members.active

      find_member_in_group = @member_active.map(&:id)

      raise ExceptionHandler::UnprocessableEntity, "You have joined in #{@group.name} already" if find_member_in_group.include?(member_id)

      if GroupMember.have_request_group?(@group, @current_member)
        Group.accept_group(@current_member, { id: @group.id, member_id: @current_member.id } )
        @new_request = true
        @joined = true
      else
        @request_group = @group.request_groups.where(member_id: member_id).first_or_create do |request_group|
          request_group.member_id = member_id
          request_group.group_id = @group.id
          request_group.save!
          @new_request = true
          @current_member.flush_cache_ask_join_groups
          RequestGroupWorker.perform_async(member_id, @group.id) unless Rails.env.test?
        end
      end
    end

  end

  def cancel_group
    if params[:friend_id]
      @group = Group.cancel_group(@current_member, Member.cached_find(params[:friend_id]), @group)
    else
      @group = Group.deny_request_join_group_my_self(@current_member, @group)
    end
  end

  def leave_group
    @group = Group.leave_group(@current_member, @group)
  end

  def kick_member
    @group = @group.kick_member_out_group(@current_member, group_params[:friend_id])
  end

  def promote_admin
    @group = @group.promote_admin(@current_member, group_params[:friend_id], group_params[:admin])
  end

  def delete_group
    @group  = @current_member.delete_group(group_params[:group_id])
  end

  def set_public
    if @group.update!(edit_group_params)
      render status: :created
    else
      @error_message = @group.errors.messages[:public_id][0]
      render status: :unprocessable_entity
    end
  end

  #### deprecated ####

  # def notification
  #   @notification = @group.set_notification(group_params[:member_id])
  # end

  private

  def only_admin_of_group
    Group::ListMember.new(set_group).raise_error_not_admin(@current_member)
  end

  def set_group
    @group = Group.cached_find(params[:id])
  end

  def options_params
    params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request)
  end

  def poll_group_params
    params.permit(:id, :member_id, :next_cursor, :type)
  end

  def group_params
    params.permit(:id, :name, :photo_group, :group_id, :member_id, :friend_id, :description, :public, :admin, :cover, :cover_preset, :admin_post_only, :need_approve, :public_id, :opened)
  end

  def edit_group_params
    params.permit(:name, :description, :photo_group, :cover, :admin_post_only, :need_approve, :public, :public_id, :cover_preset, :opened)
  end
end
