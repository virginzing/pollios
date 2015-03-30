class FriendsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :compress_gzip, only: [:list_of_group, :collection_profile, :follower_of_friend, :following_of_friend, :friend_of_friend, :list_of_vote, :list_friend, :list_of_watched,  :list_request, :search_friend, :polls, :profile, :list_of_poll, :my_following, :my_follower]
  before_action :set_current_member
  before_action :set_friend, only: [:profile, :list_of_poll, :list_of_vote, :list_of_group, :list_of_watched]
  before_action :load_resource_poll_feed, only: [:list_of_bookmark, :list_of_save_poll_later, :list_of_poll, :list_of_vote, :list_of_watched, :list_friend]

  expose(:watched_poll_ids) { @current_member.cached_watched.map(&:poll_id) }
  expose(:share_poll_ids) { @current_member.cached_shared_poll.map(&:poll_id) }
  expose(:hash_member_count) { @hash_member_count }

  def add_friend
    @detail_friend, @status = Friend.add_friend(friend_params)
    render status: @detail_friend ? :created : :unprocessable_entity
  end

  def add_close_friend
    @friend = Friend.add_or_un_close_friend(friend_params, true)
  end

  def unclose_friend
    @friend = Friend.add_or_un_close_friend(friend_params, false)
  end

  def following
    @friend = Friend.add_following(@current_member, friend_params)
    render status: @friend ? :created : :unprocessable_entity
  end

  def unfollow
    @friend = Friend.unfollow(friend_params)
    render status: @friend ? :created : :unprocessable_entity
  end

  def unfriend
    @friend = Friend.unfriend(friend_params)
    render status: @friend ? :created : :unprocessable_entity
  end

  def accept_friend
    @detail_friend, @status, @active = Friend.accept_or_deny_freind(friend_params, true)
    render status: @detail_friend ? :created : :unprocessable_entity
  end

  def deny_friend
    @friend, @status, @active = Friend.accept_or_deny_freind(friend_params, false)
    render status: @friend ? :created : :unprocessable_entity
  end


  def block_friend
    @friend = Friend.block_or_unblock_friend(friend_params, true)
    render status: @friend ? :created : :unprocessable_entity
  end

  def unblock_friend
    @friend = Friend.block_or_unblock_friend(friend_params, false)
    render status: @friend ? :created : :unprocessable_entity
  end

  def mute_friend
    @friend = @current_member.mute_or_unmute_friend(friend_params, true)
  end

  def unmute_friend
    @friend = @current_member.mute_or_unmute_friend(friend_params, false)
  end

  def search_friend
    @search = Member.search_member(friend_params)
    init_list_friend ||= Member::ListFriend.new(@current_member)
    @is_friend = Friend.check_add_friend?(@current_member, @search, init_list_friend.check_is_friend)
    TypeSearch.create_log_search_users_and_groups(@current_member, friend_params[:q])
  end

  def friend_of_friend
    @friend = Friend.friend_of_friend(friend_params)
    is_friend(@friend) if @friend.present?
  end

  def following_of_friend
    find_user = Member.cached_find(friend_params[:friend_id])
    init_list_friend ||= Member::ListFriend.new(find_user)
    @list_following = init_list_friend.following
    @is_friend = Friend.check_add_friend?(find_user, @list_following, init_list_friend.check_is_friend) if @list_following.present?
  end

  def follower_of_friend
    @friend = Friend.follower_of_friend(friend_params)
    is_friend(@friend) if @friend.present?
  end

  def list_of_poll
    if derived_version == 6
      if params[:member_id] == params[:friend_id]
        @init_poll = V6::MyPollInProfile.new(@current_member, options_params)
        @list_polls, @next_cursor = @init_poll.get_my_poll
        @group_by_name = @init_poll.group_by_name
      else
        @init_poll = V6::FriendPollInProfile.new(@current_member, @find_friend, poll_friend_params)
        @list_polls, @next_cursor = @init_poll.get_friend_poll_feed
        @group_by_name = @init_poll.group_by_name
      end
    end
  end


  def list_of_vote
    if derived_version == 6
      if params[:member_id] == params[:friend_id]
        @init_poll = V6::MyPollInProfile.new(@current_member, options_params)
        @list_polls, @next_cursor = @init_poll.get_my_vote
        @group_by_name = @init_poll.group_by_name
      else
        @init_poll = V6::FriendPollInProfile.new(@current_member, @find_friend, poll_friend_params)
        @list_polls, @next_cursor = @init_poll.get_friend_vote_feed
        @group_by_name = @init_poll.group_by_name
      end
    else
      if params[:member_id] == params[:friend_id]
        @init_poll = MyPollInProfile.new(@current_member, options_params)
        @polls = @init_poll.my_vote.paginate(page: params[:next_cursor])
      else
        @init_poll = MyPollInProfile.new(@find_friend, options_params)
        @init_poll_friend = FriendPollInProfile.new(@current_member, @find_friend, poll_friend_params)
        @polls = @init_poll_friend.get_vote_friend_with_visibility.paginate(page: params[:next_cursor])
      end
      poll_helper
    end
  end

  def list_of_watched
    if derived_version == 6
      if params[:member_id] == params[:friend_id]
        @init_poll = V6::MyPollInProfile.new(@current_member, options_params)
        @list_polls, @next_cursor = @init_poll.get_my_watch
        @group_by_name = @init_poll.group_by_name
      else
        @init_poll = V6::FriendPollInProfile.new(@current_member, @find_friend, poll_friend_params)
        @list_polls, @next_cursor = @init_poll.get_friend_watch_feed
        @group_by_name = @init_poll.group_by_name
      end
    else
      if params[:member_id] == params[:friend_id]
        @init_poll = MyPollInProfile.new(@current_member, options_params)
        @polls = @init_poll.my_watched.paginate(page: params[:next_cursor])
      else
        @init_poll = MyPollInProfile.new(@find_friend, options_params)
        @init_poll_friend = FriendPollInProfile.new(@current_member, @find_friend, poll_friend_params)
        @polls = @init_poll_friend.get_watched_friend_with_visibility.paginate(page: params[:next_cursor])
      end
      poll_helper
    end
  end

  def list_of_save_poll_later
    @init_poll = V6::MyPollInProfile.new(@current_member, options_params)
    @list_polls, @next_cursor = @init_poll.get_my_save_later
    @group_by_name = @init_poll.group_by_name
  end

  def list_of_bookmark
    @init_poll = V6::MyPollInProfile.new(@current_member, options_params)
    @list_polls, @next_cursor = @init_poll.get_my_bookmark
    @group_by_name = @init_poll.group_by_name
  end

  def check_my_vote_flush_cache?(member, vote_poll_count)
    member.flush_cache_my_vote if vote_poll_count != member.cached_my_voted.count
  end

  def check_friend_vote_flush_cache?(friend, member, vote_poll_count)
    friend.flush_cache_friend_vote if vote_poll_count != friend.cached_voted_friend_count(member)
  end

  def check_my_watch_flush_cache?(member, watch_poll_count)
    member.flush_cache_my_watch if watch_poll_count != member.cached_watched
  end

  def check_friend_watch_flush_cache?(friend, member, watch_poll_count)
    friend.flush_cache_friend_watch if watch_poll_count != friend.cached_watched_friend_count(member)
  end

  def list_of_group

    if params[:member_id] == params[:friend_id]
      init_list_group = Member::ListGroup.new(@current_member)
      @groups = init_list_group.active_non_virtual
      @hash_member_count = init_list_group.hash_member_count
    else
      init_list_group = Friend::ListGroup.new(@current_member, @find_friend)

      if @find_friend.company?
        @groups = init_list_group.together_group_of_official_non_virtual
        @hash_member_count = init_list_group.hash_member_count_of_official
      else
        @groups = init_list_group.together_group_of_friend_non_virtual
        @hash_member_count = init_list_group.hash_member_count_of_friend
      end
    end
    
  end

  ## below is my profile ##

  def list_friend
    @friend_active = Member.list_friend_active
    @your_request = Member.list_your_request
    @friend_request = Member.list_friend_request
  end

  def my_following
    @list_following = @current_member.cached_get_following
    @is_friend = Friend.add_friend?(@current_member, @list_following) if @list_following.present?
  end

  def my_follower
    @list_follower = @current_member.cached_get_follower
    @is_friend = Friend.add_friend?(@current_member, @list_follower) if @list_follower.present?
  end

  def profile
    init_list_friend ||= Member::ListFriend.new(@current_member)
    @is_friend = Friend.check_add_friend?(@current_member, [@find_friend], init_list_friend.check_is_friend)
  end

  def collection_profile
    if friend_params[:member] == friend_params[:friend_id]
    
      init_list_friend ||= Member::ListFriend.new(@current_member)

      @list_friend = init_list_friend.active
      @list_friend_is_friend = Friend.check_add_friend?(@current_member, @list_friend, init_list_friend.check_is_friend) if @list_friend.present?

      @list_following = init_list_friend.following
      @list_following_is_friend = Friend.check_add_friend?(@current_member, @list_following, init_list_friend.check_is_friend) if @list_following.present?

      @list_follower = find_user.celebrity? ? init_list_friend.follower : []
      @list_follower_is_friend = Friend.check_add_friend?(@current_member, @list_follower, init_list_friend.check_is_friend) if @list_follower.present?

      @list_block = init_list_friend.block
      @list_block_is_friend = Friend.check_add_friend?(@current_member, @list_block, init_list_friend.check_is_friend) if @list_block.present?

    else

      find_user = Member.cached_find(friend_params[:friend_id])

      init_list_friend ||= Member::ListFriend.new(find_user)
      init_list_friend_of_member ||= Member::ListFriend.new(@current_member)

      @list_friend = init_list_friend.active
      @list_friend_is_friend = Friend.check_add_friend?(@current_member, @list_friend, init_list_friend_of_member.check_is_friend) if @list_friend.present?

      @list_following = init_list_friend.following
      @list_following_is_friend = Friend.check_add_friend?(@current_member, @list_following, init_list_friend_of_member.check_is_friend) if @list_following.present?

      @list_follower = (find_user.celebrity? || find_user.company?) ? init_list_friend.follower : []
      @list_follower_is_friend = Friend.check_add_friend?(@current_member, @list_follower, init_list_friend_of_member.check_is_friend) if @list_follower.present?

    end
  end

  ###

  def poll_helper
    @poll_series, @poll_nonseries = Poll.split_poll(@polls)
    @group_by_name ||= @init_poll.group_by_name
    @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
    @total_entries = @polls.total_entries
  end

  def is_friend(list_compare)
    @is_friend = Friend.add_friend?(@current_member, list_compare)
  end


  private

  def set_friend
    @find_friend = Member.cached_find(params[:friend_id])
  end

  def poll_friend_params
    params.permit(:friend_id, :member_id, :next_cursor, :type)
  end

  def friend_params
    params.permit(:friend_id, :q, :member_id)
  end

  def options_params
    params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request, :group_id, :friend_id)
  end


end
