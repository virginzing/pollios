class MembersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_current_member, only: [:detail_friend, :stats, :update_profile]
  before_action :history_voted_viewed, only: [:detail_friend]
  before_action :compress_gzip, only: [:detail_friend]
  before_action :signed_user, only: [:index]

  expose(:list_friend) { current_member.friend_active.pluck(:followed_id) }
  expose(:friend_request) { current_member.get_your_request.pluck(:id) }
  expose(:members) { |default| default.paginate(page: params[:page]) }
 
  def detail_friend
    @find_friend = Member.find(params[:friend_id])
    poll = @find_friend.polls.includes(:member)
    @poll_series, @poll_nonseries, @next_cursor = Poll.split_poll(poll)
    @is_friend = Friend.add_friend?(@current_member.id, [@find_friend]) if @find_friend.present?
  end

  def update_profile
    if @current_member.update(update_profile_params.except("member_id"))
      @current_member
    else
      @error_message = @current_member.errors.messages
    end
  end

  def stats
    @stats_all = @current_member.get_stats_all
  end

  def index
  end

  def profile
  end

  def clear
    current_member.history_votes.delete_all
    flash[:success] = "Clear successfully."
    redirect_to root_url
  end

  private


  def update_profile_params
    params.permit(:member_id, :username, :fullname, :avatar, :gender, :birthday, :province_id, :sentai_name)
  end

  
end
