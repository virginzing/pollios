class Friend < ActiveRecord::Base
  include FriendsHelper
  include SymbolHash

  belongs_to :follower, class_name: "Member", touch: true
  belongs_to :followed, class_name: "Member", touch: true

  validates :follower_id, presence: true
  validates :followed_id, presence: true

  # scope :search_member, -> (member_id, friend_id) { find_by(follower_id: member_id, followed_id: friend_id) }
  # scope :search_friend, -> (friend_id, member_id) { find_by(follower_id: friend_id, followed_id: member_id) }

  def self.following_of_friend(friend)
    friend_id = friend[:friend_id]
    begin
      find_friend = Member.find(friend_id)
      following_from_cached = find_friend.cached_get_following
    rescue => e
      []
    end
  end

  def self.add_friend(friend_params)
    begin
      Friend.transaction do
        find_invite_new_record = false
        find_invitee_new_record = false

        @member = Member.cached_find(friend_params[:member_id])
        @friend = Member.cached_find(friend_params[:friend_id])

        init_member_list_friend ||= Member::ListFriend.new(@member)
        member_friend_active = init_member_list_friend.active.map(&:id)
        member_invite_friend = init_member_list_friend.your_request.map(&:id)

        fail ExceptionHandler::UnprocessableEntity, "You and #{@friend.get_name} is friends." if member_friend_active.include?(@friend.id)
        fail ExceptionHandler::UnprocessableEntity, "You had already added friend with #{@friend.get_name}" if member_invite_friend.include?(@friend.id)

        find_invite = where(follower: @member, followed: @friend).first_or_initialize do |friend|
          friend.follower = @member
          friend.followed = @friend
          friend.status = :invite
          friend.save!
          find_invite_new_record = true
        end

        find_invitee = where(follower: @friend, followed: @member).first_or_initialize do |friend|
          friend.follower = @friend
          friend.followed = @member
          friend.status = :invitee
          friend.save!
          find_invitee_new_record = true
        end

        unless find_invite_new_record
          if find_invite.invitee?
            find_invite.update!(status: :friend)
            find_invitee.update!(status: :friend)
            Activity.create_activity_friend( @member, @friend , ACTION[:become_friend])
            Activity.create_activity_friend( @friend, @member , ACTION[:become_friend])
            AddFriendWorker.perform_async(@member.id, @friend.id, { accept_friend: true, action: ACTION[:become_friend] } ) unless Rails.env.test?
          else
            find_invite.update!(status: :invite)
            AddFriendWorker.perform_async(@member.id, @friend.id, {action: ACTION[:request_friend]} ) unless Rails.env.test? ## option
          end
        end

        unless find_invitee_new_record
          if find_invitee.invitee?
            find_invitee.update!(status: :friend)
            find_invite.update!(status: :friend)
            Activity.create_activity_friend( @member, @friend , ACTION[:become_friend])
            Activity.create_activity_friend( @friend, @member , ACTION[:become_friend])
            AddFriendWorker.perform_async(@friend.id, @member.id, { accept_friend: true, action: ACTION[:become_friend] } ) unless Rails.env.test?
          else
            unless find_invitee.friend?
              find_invitee.update!(status: :invitee)
            end
          end
        end

        if find_invite_new_record
          AddFriendWorker.perform_async(@member.id, @friend.id, { action: ACTION[:request_friend] } ) unless Rails.env.test?
        end

        FlushCached::Member.new(@member).clear_list_friends
        FlushCached::Member.new(@friend).clear_list_friends

      end

      true
    end
  end

  def self.add_or_un_close_friend(friend, status)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    begin
      find_by(follower_id: member_id, followed_id: friend_id).update!(close_friend: status)
    rescue => e
      nil
    end
  end


  def self.check_been_friend(is_friend, member_id, friend_id)
    find_no_friend = where(follower_id: member_id, followed_id: friend_id).having_status(:nofriend).first
    if find_no_friend.present? && is_friend
      status = :friend
      find_no_friend.update(status: status)
    elsif find_no_friend.present?
      status = :invite
      find_no_friend.update(status: status)
    elsif is_friend
      status = :friend
      create!(follower_id: member_id, followed_id: friend_id, status: status)
    else
      status = :invite
      create!(follower_id: member_id, followed_id: friend_id, status: status)
    end
    status
  end

  def self.add_following(member, options)
    friend_id = options[:friend_id]
    member_id = options[:member_id]

    friend = Member.cached_find(friend_id)

    init_list_member = Member::ListFriend.new(member)

    find_is_friend = where(follower_id: member_id, followed_id: friend_id, following: false).first

    fail ExceptionHandler::UnprocessableEntity, "You had followed this official account already." if init_list_member.following.map(&:id).include?(friend.id)

    if find_is_friend.present?
      find_is_friend.update(following: true)
    else
      create!(follower_id: member_id, followed_id: friend_id, status: :nofriend, following: true)
    end

    FlushCached::Member.new(member).clear_list_friends
    FlushCached::Member.new(friend).clear_list_followers

    Activity.create_activity_friend( member, friend ,'Follow')
    friend
  end

  def self.unfollow(options)
    friend_id = options[:friend_id]
    member_id = options[:member_id]

    member = Member.cached_find(member_id)
    friend = Member.cached_find(friend_id)

    init_list_member = Member::ListFriend.new(member)

    fail ExceptionHandler::UnprocessableEntity, "You're not follow this official before." unless init_list_member.following.map(&:id).include?(friend.id)

    find_following = where(follower_id: member_id, followed_id: friend_id, status: -1).first

    if find_following.present?
      FlushCached::Member.new(member).clear_list_friends
      FlushCached::Member.new(friend).clear_list_followers
      find_following.destroy
    else
      false
    end
  end

  def self.unfriend(friend)
    begin
      friend_id = friend[:friend_id]
      member_id = friend[:member_id]

      find_member = find_by(follower_id: member_id, followed_id: friend_id)
      find_friend = find_by(follower_id: friend_id, followed_id: member_id)

      member = Member.cached_find(member_id)
      friend = Member.cached_find(friend_id)

      init_member_list_friend = Member::ListFriend.new(member)

      raise ExceptionHandler::UnprocessableEntity, "You and #{friend.get_name} not friends." unless init_member_list_friend.active.map(&:id).include?(friend.id)

      if find_member && find_friend
        check_that_follow(member, find_member, friend, find_friend)
        FlushCached::Member.new(member).clear_list_friends
        FlushCached::Member.new(friend).clear_list_friends
      end

      [find_member, find_friend]
    end
  end

  def self.accept_or_deny_freind(friend, accept)
    begin
      friend_id = friend[:friend_id]
      member_id = friend[:member_id]

      find_member = find_by(follower_id: member_id, followed_id: friend_id)
      find_friend = find_by(follower_id: friend_id, followed_id: member_id)

      member = Member.cached_find(member_id)
      friend = Member.cached_find(friend_id)

      init_member_list_friend ||= Member::ListFriend.new(member)

      if accept
        active_status = true
        raise ExceptionHandler::UnprocessableEntity, "#{friend.get_name} has cancelled to request friends." unless find_member.present?
        raise ExceptionHandler::UnprocessableEntity, "This request was cancelled." unless find_friend.present?
        raise ExceptionHandler::UnprocessableEntity, "My friend has over 500 people." if (init_member_list_friend.friend_count >= member.friend_limit)
        raise ExceptionHandler::UnprocessableEntity, "Your friend has over 500 people." if (Member::ListFriend.new(friend).friend_count >= friend.friend_limit)
        raise ExceptionHandler::UnprocessableEntity, "You and #{friend.get_name} is friends." if init_member_list_friend.active.map(&:id).include?(friend.id)
        
        find_member.update_attributes!(active: active_status, status: :friend)
        find_friend.update_attributes!(active: active_status, status: :friend)

        Activity.create_activity_friend( member, friend , ACTION[:become_friend])
        Activity.create_activity_friend( friend, member , ACTION[:become_friend])

        AddFriendWorker.perform_async(member.id, friend.id, { accept_friend: true, action: ACTION[:become_friend] } ) unless Rails.env.test?
        
        FlushCached::Member.new(member).clear_list_followers
        FlushCached::Member.new(friend).clear_list_followers
      else
        raise ExceptionHandler::UnprocessableEntity, "#{friend.get_name} had already accepted your request." if init_member_list_friend.active.map(&:id).include?(friend.id)
        raise ExceptionHandler::UnprocessableEntity, "#{friend.get_name} had already denied your request." unless init_member_list_friend.cached_all_friends.map(&:id).include?(friend.id)

        check_that_follow(member, find_member, friend, find_friend)
        NotifyLog.check_update_cancel_request_friend_deleted(member, friend)
      end

      FlushCached::Member.new(member).clear_list_friends
      FlushCached::Member.new(friend).clear_list_friends
      # [friend, :friend, active_status]
      true
    end
  end

  def self.check_that_follow(member_object, find_member, friend_object, find_friend)
    if find_member.present?
      unless find_member.following
        find_friend.update!(status: :nofriend)
        find_member.destroy
      else
        find_member.update!(status: :nofriend)
      end
    end
    
    if find_friend.present?
      unless find_friend.following
        find_old_member = Friend.where(follower: member_object, followed: friend_object).first

        if find_old_member.present?
          find_old_member.update!(status: :nofriend)
        end

        find_friend.destroy
      else
        find_friend.update!(status: :nofriend)
      end
    end

    FlushCached::Member.new(member_object).clear_list_followers
    FlushCached::Member.new(friend_object).clear_list_followers
    
    true
  end

  def self.block_or_unblock_friend(friend, type_block)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    find_member = find_by(follower_id: member_id, followed_id: friend_id)
    find_friend = find_by(follower_id: friend_id, followed_id: member_id)

    member = Member.cached_find(member_id)
    friend = Member.cached_find(friend_id)

    begin
      if find_member && find_friend
        find_member.update_attributes!(block: type_block)
        find_friend.update_attributes!(visible_poll: !type_block)

        FlushCached::Member.new(member).clear_list_friends
        FlushCached::Member.new(friend).clear_list_friends
        
        FlushCached::Member.new(member).clear_list_followers
        FlushCached::Member.new(friend).clear_list_followers
      end
      true
    rescue => e
      puts "error => #{e}"
      nil
    end
  end

  def self.add_friend?(member_obj, search_member)
    check_my_friend = []

    my_friend = member_obj.cached_get_friend_active.map(&:id)
    your_request = member_obj.cached_get_your_request.map(&:id)
    friend_request = member_obj.cached_get_friend_request.map(&:id)
    my_following = member_obj.cached_get_following.map(&:id)
    block_friend = member_obj.cached_block_friend.map(&:id)

    search_member.each do |member|
      if my_friend.include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :friend]
      elsif your_request.include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :invite]
      elsif friend_request.include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :invitee]
      elsif block_friend.include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :block]
      else
        hash = Hash["add_friend_already" => false, "status" => :nofriend]
      end

      if member.celebrity? || member.brand?
        my_following.include?(member.id) ? hash.merge!({"following" => true }) : hash.merge!({"following" => false })
      else
        hash.merge!({"following" => "" })
      end
      check_my_friend << hash
    end

    return check_my_friend
  end

  def self.check_add_friend?(member, list_members, check_is_friend)
    check_my_friend = []

    list_members.each do |member|
      if check_is_friend[:active].include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :friend]
      elsif check_is_friend[:your_request].include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :invite]
      elsif check_is_friend[:friend_request].include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :invitee]
      elsif check_is_friend[:block].include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :block]
      else
        hash = Hash["add_friend_already" => false, "status" => :nofriend]
      end

      if member.celebrity? || member.company?
        check_is_friend[:following].include?(member.id) ? hash.merge!({"following" => true }) : hash.merge!({"following" => false })
      else
        hash.merge!({"following" => "" })
      end
      check_my_friend << hash
    end

    return check_my_friend
  end



  def self.flush_cached_friend(member_id, friend_id)
    Rails.cache.delete([ member_id, 'friend_active'])
    Rails.cache.delete([ member_id, 'your_request'])
    Rails.cache.delete([ member_id, 'friend_request'])
    Rails.cache.delete([ member_id, 'following'])
    Rails.cache.delete([ member_id, 'follower'])

    Rails.cache.delete([ friend_id, 'friend_active'])
    Rails.cache.delete([ friend_id, 'your_request'])
    Rails.cache.delete([ friend_id, 'friend_request'])
    Rails.cache.delete([ friend_id, 'following'])
    Rails.cache.delete([ friend_id, 'follower'])
  end

end
