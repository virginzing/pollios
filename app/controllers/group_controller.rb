class GroupController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :set_current_member, only: [:set_public, :members, :cancel_ask_join_group, :accept_request_group, :request_group, :edit_group, :promote_admin, :kick_member, :detail_group, :my_group, :build_group, :accept_group, :cancel_group, :leave_group, :poll_available_group, :poll_group, :notification, :add_friend_to_group]
  before_action :set_group, only: [:delete_photo_group, :delete_cover_group, :set_public, :members, :cancel_ask_join_group, :accept_request_group, :request_group, :delete_group, :edit_group, :promote_admin, :kick_member, :add_friend_to_group, :detail_group, :poll_group, :delete_poll, :notification, :poll_available_group, :leave_group, :cancel_group]
  before_action :compress_gzip, only: [:my_group, :poll_group, :detail_group, :poll_available_group, :members]
  
  before_action :load_resource_poll_feed, only: [:poll_group, :poll_available_group]

  expose(:watched_poll_ids) { @current_member.cached_watched.map(&:poll_id) }
  expose(:share_poll_ids) { @current_member.cached_shared_poll.map(&:poll_id) }
  expose(:hash_member_count) { @hash_member_count }

  def load_group
    @group = Group.cached_find(params[:group_id])
    render layout: false
  end

  def my_group
    init_list_group = Member::ListGroup.new(@current_member)
    @group_active = init_list_group.active
    @group_inactive = init_list_group.inactive
    @hash_member_count = init_list_group.hash_member_count
  end

  def build_group
    @group =  Group.build_group(@current_member, group_params)
  end

  def edit_group
    @group.update!(edit_group_params)
    init_cover_group = ImageUrl.new(edit_group_params[:cover])

    if edit_group_params[:cover] && init_cover_group.from_image_url?
      @group.remove_old_cover
      @group.update_column(:cover, init_cover_group.split_cloudinary_url)
    end

    Company::TrackActivityFeedGroup.new(@current_member, @group, "update").tracking if @group.is_company?
    FlushCached::Group.new(@group).clear_list_group_all_member_in_group
  end

  def add_friend_to_group
    @group = Group.add_friend_to_group(@group, @current_member, group_params[:friend_id])
  end

  def accept_group
    @group = Group.accept_group(@current_member, group_params)
  end

  def accept_request_group
    @group = Group.accept_request_group(@current_member, Member.cached_find(params[:friend_id]), @group)
  end

  def cancel_ask_join_group
    @group = Group.cancel_ask_join_group(@current_member, params[:friend_id], @group)
  end

  def poll_group
    @init_poll = PollOfGroup.new(@current_member, @group, options_params)
    @polls = @init_poll.get_poll_of_group.paginate(page: params[:next_cursor])
    poll_helper
  end

  def members
    @group_members ||= Group::ListMember.new(@group)
    @member_active = @group_members.active
    @member_pending = @group_members.pending
    @member_request = @group.members_request
  end

  def poll_available_group
    if derived_version == 6
      @init_poll = V6::PollOfGroup.new(@current_member, @group, options_params)
      @list_polls, @next_cursor = @init_poll.get_poll_available_of_group
      @group_by_name = @init_poll.group_by_name
    else
      @init_poll = PollOfGroup.new(@current_member, @group, options_params)
      @polls = @init_poll.get_poll_available_of_group.paginate(page: params[:next_cursor])
      poll_helper
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
        @group.decrement!(:poll_count)

        find_poll_in_group.first.poll.member.flush_cache_about_poll
        DeletePoll.create_log(find_poll_in_group.first.poll)
        wants.json { render json: Hash["response_status" => "OK"] }
      else
        wants.json { render json: Hash["response_status" => "ERROR", "response_message" => "Unable to delete poll"] }
      end
    end
  end

  def detail_group
    @group_members ||= Group::ListMember.new(@group)
    @member_active = @group_members.active
    @member_pending = @group_members.pending
    @member_request = @group.members_request
    # @is_admin = @member_active.collect {|e| [e.id, e.admin] }.collect{|e| e.last if e.first == @current_member.id }.compact.first
  end

  def request_group

    unless @group.need_approve
      Group.accept_request_group(@current_member, @current_member, @group)
      @new_request = true
      @joined = true
    else
      @joined = false
      member_id = params[:member_id]
      @member 
      @new_request = false

      begin
        @group_members ||= Group::ListMember.new(@group)
        @member_active = @group_members.active

        find_member_in_group = @member_active.map(&:id)

        raise ExceptionHandler::Forbidden, "You have joined in #{@group.name} already" if find_member_in_group.include?(member_id)
        
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

  end

  def cancel_group
    @group = @current_member.cancel_or_leave_group(group_params[:id], "C")
  end

  def leave_group
    @group = @current_member.cancel_or_leave_group(group_params[:id], "L")
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

  def notification
    @notification = @group.set_notification(group_params[:member_id]) 
  end

  # def public_id
  #   begin
  #     @group = @group.update!(public_id: group_params[:public_id])
  #   rescue ActiveRecord::RecordInvalid => invalid
  #     @group = nil
  #     @error_message = invalid.record.errors.messages[:public_id][0]
  #     render status: :unprocessable_entity
  #   end
  # end

  def set_public
    begin
      @group.update_attributes!(public: edit_group_params[:public], public_id: edit_group_params[:public_id])
    rescue ActiveRecord::RecordInvalid => invalid
      @group = nil
      @error_message = invalid.record.errors.messages[:public_id][0]
      render status: :unprocessable_entity
    end
  end

  def group_update
    group_id = group_update_params[:id]
    member_id = group_update_params[:pk]
    @admin_status = group_update_params[:value] == "1" ? false : true

    #"value"=>"2" is admin

    find_member_in_group = GroupMember.where("member_id = ? AND group_id = ?", member_id, group_id).first
    find_member = find_member_in_group.member

    respond_to do |format|
      if find_member_in_group.present?
        find_group = find_member_in_group.group

        if find_group.is_company? ## Is it group of company?

          find_role_member = find_member.roles.first

          if find_role_member.present?
            find_exist_role_member = find_role_member.resource.get_company
          end

          if find_role_member.nil? || (find_exist_role_member.id == find_group.get_company.id)
            find_member_in_group.update!(is_master: @admin_status)

            if @admin_status
              find_member.add_role :group_admin, find_group
            else
              find_member.remove_role :group_admin, find_group
            end
          else
            # raise ExceptionHandler::Forbidden, "You have already exist admin of #{find_exist_role_member.name} Company"
            format.json { render text: "You have already exist admin of #{find_exist_role_member.name} Company" , status: :unprocessable_entity }
          end

        else
          find_member_in_group.update!(is_master: @admin_status)
        end

        FlushCached::Member.new(find_member).clear_list_groups

        format.json { render json: [
              {value: 1, text: 'Member'},
              {value: 2, text: 'Admin'}
      ], root: false }
      else
        format.json { render text: "Unable update record." , status: :unprocessable_entity }
      end 
    end
  end


  def delete_photo_group
    Group.transaction do
      begin
        @group.remove_photo_group!
        @group.save
        flash[:success] = "Delete photo group successfully."
      rescue => e
        flash[:error] = e.message
      end

      respond_to do |format|
        format.html { redirect_to company_edit_group_path(@group) }
      end
    end
  end

  def delete_cover_group
    Group.transaction do
      begin
        @group.remove_cover!
        @group.save
        flash[:success] = "Delete cover group successfully."
      rescue => e
        flash[:error] = e.message
      end

      respond_to do |format|
        format.html { redirect_to company_edit_group_path(@group) }
      end
    end
  end

  private

  def set_group
    @group = Group.cached_find(params[:id])
  end

  def group_update_params
    params.permit(:pk, :id, :value)
  end

  def options_params
    params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request)
  end

  def poll_group_params
    params.permit(:id, :member_id, :next_cursor, :type)  
  end

  def group_params
    params.permit(:id, :name, :photo_group, :group_id, :member_id, :friend_id, :description, :public, :admin, :cover, :admin_post_only, :need_approve, :public_id)
  end

  def edit_group_params
    params.permit(:name, :description, :photo_group, :cover, :admin_post_only, :need_approve, :public, :public_id)
  end
end
