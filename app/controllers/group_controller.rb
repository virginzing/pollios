class GroupController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :set_current_member, only: [:detail_group, :my_group, :build_group, :accept_group, :cancel_group, :leave_group, :poll_group, :notification, :add_friend_to_group]
  before_action :set_group, only: [:add_friend_to_group, :detail_group, :poll_group, :delete_poll, :notification]
  before_action :compress_gzip, only: [:my_group, :poll_group, :detail_group]
  
  before_action :load_resource_poll_feed, only: [:poll_group]

  expose(:watched_poll_ids) { @current_member.cached_watched.map(&:poll_id) }
  expose(:share_poll_ids) { @current_member.cached_shared_poll.map(&:poll_id) }

  def my_group
    @group_active = @current_member.get_group_active
    @group_inactive = Group.joins(:group_members).where("group_members.member_id = ? AND group_members.active = 'f'", @current_member.id).
                      select("groups.*, group_members.invite_id as invite_id")
  end

  def build_group
    @group =  Group.build_group(@current_member, group_params)
  end

  def add_friend_to_group
    @group = Group.add_friend_to_group(group_params[:id], @current_member, group_params[:friend_id])
  end

  def accept_group
    @group = Group.accept_group(@current_member, group_params)
    # @group_active = @current_member.get_group_active
  end

  def poll_group
    @init_poll = PollOfGroup.new(@current_member, @group, options_params)
    @polls = @init_poll.get_poll_of_group.paginate(page: params[:next_cursor])
    poll_helper
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
        wants.json { render json: Hash["response_status" => "OK"] }
      else
        wants.json { render json: Hash["response_status" => "ERROR", "response_message" => "Unable to delete poll"] }
      end
    end
  end

  def detail_group
    @member_active ||= Member.joins(:group_members).select("members.*, group_members.is_master as admin").where("group_members.active = 't' AND group_members.group_id = ?", @group.id)
    @member_pendding ||= Member.joins(:group_members).select("members.*, group_members.is_master as admin").where("group_members.active = 'f' AND group_members.group_id = ?", @group.id)
    @is_admin = @member_active.collect {|e| [e.id, e.admin] }.collect{|e| e.last if e.first == @current_member.id }.compact.first
  end

  def cancel_group
    @group = @current_member.cancel_or_leave_group(group_params[:id], "C")
  end

  def leave_group
    @group = @current_member.cancel_or_leave_group(group_params[:id], "L")
  end

  def delete_group
    @group  = @current_member.delete_group(group_params[:group_id])
  end

  def notification
    @notification = @group.set_notification(group_params[:member_id]) 
  end

  def group_update
    group_id = group_update_params[:id]
    member_id = group_update_params[:pk]
    is_master = group_update_params[:value] == "1" ? false : true

    find_group_member = GroupMember.where("member_id = ? AND group_id = ?", member_id, group_id).first

    respond_to do |format|
      if find_group_member.present?
        find_group_member.update(is_master: is_master)
        format.json { render json: [
              {value: 1, text: 'Member'},
              {value: 2, text: 'Admin'}
      ], root: false }
      else
        format.json { render text: "Unable update record." , status: :unprocessable_entity }
      end 
    end
  end

  private

  def set_group
    begin
      @group = Group.find(params[:id])
    rescue => e
      respond_to do |wants|
        wants.json { render json: Hash["response_status" => "ERROR", "response_message" => e.message ] }
      end
    end
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
    params.permit(:id, :name, :photo_group, :group_id, :member_id, :friend_id, :description, :public)
  end
end
