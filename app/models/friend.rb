class Friend < ActiveRecord::Base
  include FriendsHelper
  include SymbolHash

  belongs_to :follower, class_name: "Member", touch: true
  belongs_to :followed, class_name: "Member", touch: true

  validates :follower_id, presence: true
  validates :followed_id, presence: true

  scope :search_member, -> (member_id, friend_id) { where(follower_id: member_id, followed_id: friend_id).first }
  scope :search_friend, -> (friend_id, member_id) { where(follower_id: friend_id, followed_id: member_id).first }

  # def self.friend_of_friend(friend)
  #   friend_id = friend[:friend_id]

  #   begin
  #     find_friend = Member.find(friend_id)
  #     friend_from_cached = find_friend.cached_get_friend_active
  #   rescue => e
  #     []
  #   end
  # end

  def self.following_of_friend(friend)
    friend_id = friend[:friend_id]
    begin
      find_friend = Member.find(friend_id)
      following_from_cached = find_friend.cached_get_following
    rescue => e
      []
    end
  end

  # def self.follower_of_friend(friend)
  #   friend_id = friend[:friend_id]

  #   begin
  #     find_friend = Member.find(friend_id)
  #     following_from_cached = find_friend.cached_get_follower
  #   rescue => e
  #     []
  #   end
  # end


  # def self.add_friend(friend)
  #   friend_id = friend[:friend_id]
  #   member_id = friend[:member_id]

  #   begin
  #     create_new_record_friend = false
  #     find_member = Member.cached_find(member_id)
  #     find_friend = Member.cached_find(friend_id)

  #     find_invitee = where(follower_id: member_id, followed_id: friend_id).having_status(:invitee).first
  #     find_used_friend = where(follower_id: friend_id, followed_id: member_id).having_status(:nofriend).first
  #     ever_following = where(follower_id: member_id, followed_id: friend_id, following: true).having_status(:nofriend).first

  #     if find_invitee.present?
  #       find_invitee.update_attributes!(status: :friend)
  #       search_friend(friend_id, member_id).update_attributes!(status: :friend)
  #       status = :friend
  #       Activity.create_activity_friend( find_member, find_friend , ACTION[:become_friend])
  #       Activity.create_activity_friend( find_friend, find_member , ACTION[:become_friend])
  #     elsif find_used_friend
  #       find_used_friend.update(status: :invitee)
          
  #       member = where(follower_id: find_member.id, followed_id: find_friend.id).first_or_initialize do |friend|
  #         friend.follower_id = find_member.id
  #         friend.followed_id = find_friend.id
  #         friend.status = :invite
  #         friend.save!
  #         create_new_record_friend = true
  #       end
  #       member.update!(status: :invite) unless create_new_record_friend

  #       status = :invite
  #     elsif ever_following && find_friend.citizen?
  #       ever_following.update(status: :invite)
  #       create!(follower: find_friend, followed: find_member, status: :invitee)
  #       status = :invite
  #     else
  #       create!(follower_id: member_id, followed_id: friend_id, status: :invite)
  #       create!(follower_id: friend_id, followed_id: member_id, status: :invitee)
  #       status = :invite
  #     end
  #     # flush_cached_friend(member_id, friend_id)
  #     FlushCached::Member.new(find_member).clear_one_friend
  #     FlushCached::Member.new(find_friend).clear_one_friend

  #     AddFriendWorker.perform_async(find_member.id, find_friend.id, {action: ACTION[:request_friend]} ) unless Rails.env.test?
  #     [find_friend, status]
  #   rescue  => e
      
  #   end
  # end

  def self.add_friend(friend_params)
    begin
      Friend.transaction do
        find_invite_new_record = false
        find_invitee_new_record = false

        @member = Member.cached_find(friend_params[:member_id])
        @friend = Member.cached_find(friend_params[:friend_id])

        init_member_list_friend ||= Member::ListFriend.new(@member)
        member_friend_active = init_member_list_friend.active.map(&:id)

        raise ExceptionHandler::Forbidden, "You and #{@friend.get_name} is friends" if member_friend_active.include?(@friend.id)

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
            find_invitee.update!(status: :invitee) unless find_invitee.friend?
          end
        end

        if find_invite_new_record
          AddFriendWorker.perform_async(@member.id, @friend.id, {action: ACTION[:request_friend]} ) unless Rails.env.test?
        end

        FlushCached::Member.new(@member).clear_one_friend
        FlushCached::Member.new(@friend).clear_one_friend

      end

      true
    end
  end

  def self.add_or_un_close_friend(friend, status)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    begin
      search_member(member_id, friend_id).update_attributes!(close_friend: status)
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

  def self.add_following(member, friend)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    begin
      friend = Member.cached_find(friend_id)

      find_is_friend = where(follower_id: member_id, followed_id: friend_id, following: false).first

      if find_is_friend.present?
        find_is_friend.update(following: true)
      else
        create!(follower_id: member_id, followed_id: friend_id, status: :nofriend, following: true)
      end

      FlushCached::Member.new(member).clear_one_friend
      FlushCached::Member.new(friend).clear_one_follower

      Activity.create_activity_friend( member, friend ,'Follow')
      # AddFollowWorker.perform_async(member.id, friend.id, { action: 'Follow' } ) unless Rails.env.test?

      friend
    rescue => e
      puts "error => #{e}"
    end

  end

  def self.unfollow(friend)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    member = Member.cached_find(member_id)
    friend = Member.cached_find(friend_id)

    find_following = where(follower_id: member_id, followed_id: friend_id, status: -1).first

    if find_following.present?

      FlushCached::Member.new(member).clear_one_friend
      FlushCached::Member.new(friend).clear_one_follower

      find_following.destroy
    else
      false
    end
  end

  def self.unfriend(friend)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    find_member = search_member(member_id, friend_id)
    find_friend = search_friend(friend_id, member_id)

    member = Member.cached_find(member_id)
    friend = Member.cached_find(friend_id)

    init_member_list_friend = Member::ListFriend.new(member)

    raise ExceptionHandler::Forbidden, "You and #{friend.get_name} not friends" unless init_member_list_friend.active.map(&:id).include?(friend.id)

    if find_member && find_friend
      check_that_follow(member, find_member, friend, find_friend)
      FlushCached::Member.new(member).clear_one_friend
      FlushCached::Member.new(friend).clear_one_friend
    end

    [find_member, find_friend]
  end

  def self.accept_or_deny_freind(friend, accept)
    begin
      friend_id = friend[:friend_id]
      member_id = friend[:member_id]

      find_member = search_member(member_id, friend_id)
      find_friend = search_friend(friend_id, member_id)

      member = Member.cached_find(member_id)
      friend = Member.cached_find(friend_id)

      init_member_list_friend ||= Member::ListFriend.new(member)

      if accept
        active_status = true

        raise ExceptionHandler::Forbidden, "My friend has over 500 people" if (init_member_list_friend.friend_count >= member.friend_limit)
        raise ExceptionHandler::Forbidden, "Your friend has over 500 people" if (Member::ListFriend.new(friend).friend_count >= friend.friend_limit)
        raise ExceptionHandler::Forbidden, "You and #{friend.get_name} is friends" if init_member_list_friend.active.map(&:id).include?(friend.id)
        raise ExceptionHandler::NotFound, "Not found" unless where(follower: member, followed: friend).having_status(:invitee).first.present?
        
        search_member(member_id, friend_id).update_attributes!(active: active_status, status: :friend)
        search_friend(friend_id, member_id).update_attributes!(active: active_status, status: :friend)

        Activity.create_activity_friend( member, friend , ACTION[:become_friend])
        Activity.create_activity_friend( friend, member , ACTION[:become_friend])

        AddFriendWorker.perform_async(member.id, friend.id, { accept_friend: true, action: ACTION[:become_friend] } ) unless Rails.env.test?
        
      else
        check_that_follow(member, find_member, friend, find_friend)
      end

      FlushCached::Member.new(member).clear_one_friend
      FlushCached::Member.new(friend).clear_one_friend

      [friend, :friend, active_status]

    end
  end

  def self.check_that_follow(member_object, find_member, friend_object, find_friend)
    unless find_member.following
      find_friend.update!(status: :nofriend)
      find_member.destroy
    else
      find_member.update!(status: :nofriend)
    end
    
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

  def self.block_or_unblock_friend(friend, type_block)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    member = Member.cached_find(member_id)
    friend = Member.cached_find(friend_id)

    begin

      search_member(member_id, friend_id).update_attributes!(block: type_block)
      search_friend(friend_id, member_id).update_attributes!(visible_poll: !type_block)

      FlushCached::Member.new(member).clear_one_friend
      FlushCached::Member.new(friend).clear_one_friend

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
