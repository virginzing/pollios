class FriendsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :compress_gzip, only: [:list_friend, :list_request, :search_friend, :list_following, :polls, :profile, :list_of_poll]
  before_action :set_current_member
  before_action :set_friend, only: [:profile, :list_of_poll]
  before_action :history_voted_viewed, only: [:list_of_poll]


  def add_friend
    @friend = Friend.add_friend(friend_params)
    @detail_friend, @status = @friend
  end

  def following
    @friend = Friend.add_following(friend_params)
  end

  def unfollow
    @friend = Friend.unfollow(friend_params)
    puts "friend => #{@friend}"
  end

  def unfriend
    @friend = Friend.unfriend(friend_params)
  end

  def accept_friend
    @friend = Friend.accept_or_deny_freind(friend_params, true)
    @detail_friend, @status, @active = @friend
  end

  def deny_friend
    @friend = Friend.accept_or_deny_freind(friend_params, false)
  end


  def block_friend
    @friend = Friend.block_or_unblock_friend(friend_params, true)
  end

  def unblock_friend
    @friend = Friend.block_or_unblock_friend(friend_params, false)
  end

  def mute_friend
    @friend = @current_member.mute_or_unmute_friend(friend_params, true)
  end

  def unmute_friend
    @friend = @current_member.mute_or_unmute_friend(friend_params, false)
  end

  def search_friend
    @search = Member.search_member(friend_params)
    @is_friend = Friend.add_friend?(@current_member, @search) if @search.present?
    puts "is_friend #{@is_friend}"
  end

  def list_friend
    @friend_active = @current_member.get_friend_active
    @your_request = @current_member.get_your_request
    @friend_request = @current_member.get_friend_request
    # @friend_inactive = @current_member.get_friend_inactive
  end

  def list_following
    @list_following = @current_member.get_following
  end

  def list_follower
    @list_follower = @current_member.get_follower
    @is_friend = Friend.add_friend?(@current_member, @list_follower) if @list_follower.present?
  end

  def profile
    @is_friend = Friend.add_friend?(@current_member, [@find_friend]) if @find_friend.present?
  end

  def list_of_poll
    poll = @find_friend.polls.includes(:member, :campaign)
    @poll_series, @poll_nonseries, @next_cursor = Poll.split_poll(poll)
  end

  # def list_request
  #   @your_request = @current_member.get_your_request
  #   @friend_request = @current_member.get_friend_request
  # end

  private

  def set_friend
     @find_friend = Member.find_by(id: params[:friend_id])
     unless @find_friend.present?
        respond_to do |format|
          format.json { render json: Hash["response_status" => "ERROR", "response_message" => "Don't have this id of friend"]}
        end
     end
  end 

  def friend_params
    params.permit(:friend_id, :q, :member_id)
  end

end
