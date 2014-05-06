class GroupController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :set_current_member, only: [:my_group, :accept_group, :cancel_group, :leave_group, :poll_group]
  before_action :set_group, only: [:add_friend_to_group, :detail_group, :poll_group, :delete_poll]
  before_action :history_voted_viewed, only: [:poll_group]
  before_action :compress_gzip, only: [:my_group, :poll_group, :detail_group]

  def my_group
    @group_active = @current_member.get_group_active
    @group_inactive = Group.joins(:group_members).where("group_members.member_id = ? AND group_members.active = 'f'", @current_member.id).
                      select("groups.*, group_members.invite_id as invite_id")
  end

  def build_group
    @group =  Group.build_group(group_params)
  end

  def add_friend_to_group
    @group = Group.add_friend_to_group(group_params[:id], group_params[:member_id], group_params[:friend_id])
  end

  def accept_group
    @group = Group.accept_group(group_params)
    # @group_active = @current_member.get_group_active
  end

  def poll_group
    query = @group.polls.includes(:member).paginate(page: poll_group_params[:next_cursor]).order("created_at desc")
    @polls = Poll.filter_type(query, poll_group_params[:type])
    your_group = @current_member.get_group_active
    @group_by_name = Hash[your_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group, "member_count" => f.member_count, "poll_count" => f.poll_count]] }]
    @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
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
    @member_active = @group.get_member_active
    @member_pendding = @group.get_member_inactive
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

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def poll_group_params
    params.permit(:id, :member_id, :next_cursor, :type)  
  end

  def group_params
    params.permit(:id, :name, :photo_group, :group_id, :member_id, :friend_id, :description)
  end
end
