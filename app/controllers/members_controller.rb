class MembersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_current_member, only: [:activate, :all_request, :my_profile, :activity, :detail_friend, :stats, :update_profile, :notify]
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
    if @current_member.update_attributes!(update_profile_params.except(:member_id, :avatar))
      if update_profile_params[:avatar]
        Member.update_avatar(@current_member, update_profile_params[:avatar])
      end
      @member = Member.find(@current_member.id)
    else
      @error_message = @current_member.errors.messages
    end
  end

  def all_request
    @your_request = @current_member.cached_get_your_request
    @friend_request = @current_member.cached_get_friend_request
    @group_inactive = Group.joins(:group_members).where("group_members.member_id = ? AND group_members.active = 'f'", @current_member.id).
                      select("groups.*, group_members.invite_id as invite_id")
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

  def activate_account
    if session[:activate_id] && session[:activate_email]
      render layout: "activate"
    else
      redirect_to users_signin_url
    end
  end

  def activate
    @invite_code = InviteCode.check_valid_invite_code(activate_params[:code])
    respond_to do |format|
      if @invite_code[:status]
        @activate = @current_member.build_member_invite_code(invite_code_id: @invite_code[:object].id)
        @activate.save
        @invite_code[:object].update!(used: true)
        session[:member_id] = @current_member.id
        format.js
        format.html { redirect_to dashboard_path }
      else
        flash[:warning] = @invite_code[:message]
        format.html { redirect_to users_activate_path }
      end
    end
  end

  def clear
    current_member.history_votes.delete_all
    flash[:success] = "Clear successfully."
    redirect_to root_url
  end

  private


  def update_profile_params
    params.permit(:member_id, :username, :fullname, :avatar, :gender, :birthday, :province_id, :sentai_name, :cover, :description, :sync_facebook)
  end

  def activate_params
    params.permit(:code, :member_id)
  end

  
end
