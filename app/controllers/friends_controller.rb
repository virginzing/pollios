class FriendsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :compress_gzip, only: [:list_of_vote, :list_friend, :list_request, :search_friend, :polls, :profile, :list_of_poll, :list_following, :list_follower]
  before_action :set_current_member
  before_action :set_friend, only: [:profile, :list_of_poll, :list_of_vote]
  before_action :history_voted_viewed, only: [:list_of_poll, :list_of_vote]
  
  expose(:watched_poll_ids) { @current_member.cached_watched.map(&:poll_id) }

  def add_friend
    @friend = Friend.add_friend(friend_params)
    @detail_friend, @status = @friend
  end

  def add_close_friend
    @friend = Friend.add_or_un_close_friend(friend_params, true)
  end

  def unclose_friend
    @friend = Friend.add_or_un_close_friend(friend_params, false)
  end

  def following
    @friend = Friend.add_following(friend_params)
  end

  def unfollow
    @friend = Friend.unfollow(friend_params)
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
  end

  def list_friend_of_friend
    @friend = Friend.friend_of_friend(friend_params)
    puts "#{@friend}"
    @is_friend = Friend.add_friend?(@current_member, @friend) if @friend.present?
  end

  def list_friend
    @friend_active = @current_member.cached_get_friend_active
    @your_request = @current_member.cached_get_your_request
    @friend_request = @current_member.cached_get_friend_request
    # @friend_inactive = @current_member.get_friend_inactive
  end

  def list_following
    @list_following = @current_member.cached_get_following
    @is_friend = Friend.add_friend?(@current_member, @list_following) if @list_following.present?
  end

  def list_follower
    @list_follower = @current_member.cached_get_follower
    @is_friend = Friend.add_friend?(@current_member, @list_follower) if @list_follower.present?
  end

  def profile
    @is_friend = Friend.add_friend?(@current_member, [@find_friend]) if @find_friend.present?
  end

  def list_of_poll
    @init_poll = FriendPollInProfile.new(@current_member, @find_friend, poll_friend_params)
    @polls = @init_poll.get_poll_friend.paginate(page: params[:next_cursor])
    poll_helper
  end

  def list_of_vote
    @init_poll = FriendPollInProfile.new(@current_member, @find_friend, poll_friend_params)
    @polls = @init_poll.get_vote_friend.paginate(page: params[:next_cursor])
    poll_helper
  end

  def poll_helper
    @poll_series, @poll_nonseries = Poll.split_poll(@polls)
    @group_by_name ||= @init_poll.group_by_name
    @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
    @total_entries = @polls.total_entries
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

  def poll_friend_params
     params.permit(:friend_id, :member_id, :next_cursor, :type)
   end 

  def friend_params
    params.permit(:friend_id, :q, :member_id)
  end

end
