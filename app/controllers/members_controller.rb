class MembersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_current_member, only: [:my_profile, :activity, :detail_friend, :stats, :update_profile, :notify]
  before_action :history_voted_viewed, only: [:detail_friend]
  before_action :compress_gzip, only: [:activity, :detail_friend, :notify]
  before_action :signed_user, only: [:index, :profile]


  expose(:list_friend) { current_member.friend_active.pluck(:followed_id) }
  expose(:friend_request) { current_member.get_your_request.pluck(:id) }
  expose(:members) { |default| default.paginate(page: params[:page]) }
 
  def detail_friend
    @find_friend = Member.find(params[:friend_id])
    poll = @find_friend.polls.includes(:member, :campaign)
    @poll_series, @poll_nonseries, @next_cursor = Poll.split_poll(poll)
    @is_friend = Friend.add_friend?(@current_member, [@find_friend]) if @find_friend.present?
  end

  def update_profile
    if @current_member.update(update_profile_params.except("member_id"))
      @current_member
    else
      @error_message = @current_member.errors.messages
    end
  end

  def activity
    @activity = Activity.find_by(member_id: @current_member.id)  
  end

  def notify
    @notify = @current_member.received_notifies.order('created_at DESC').paginate(page: params[:next_cursor])
    @total_entries =  @notify.total_entries
    @next_cursor = @notify.next_page.nil? ? 0 : @notify.next_page
  end

  def stats
    @stats_all = @current_member.get_stats_all
  end

  def index
  end

  def profile
  end

  def my_profile
  end

  def check_valid_email
    @member_email = Member.where(email: params[:email]).present?
    respond_to do |wants|
      wants.json { render json: !@member_email }
    end
  end

  def check_valid_username
    @member_username = Member.where(username: params[:username]).present?
    respond_to do |wants|
      wants.json { render json: !@member_username }
    end
  end

  def clear
    current_member.history_votes.delete_all
    flash[:success] = "Clear successfully."
    redirect_to root_url
  end

  private


  def update_profile_params
    params.permit(:member_id, :username, :fullname, :avatar, :gender, :birthday, :province_id, :sentai_name, :cover, :description)
  end

  
end
