class Friend < ActiveRecord::Base
  include FriendsHelper

  belongs_to :follower, class_name: "Member"
  belongs_to :followed, class_name: "Member"

  after_commit :flush_cached

  validates :follower_id, presence: true
  validates :followed_id, presence: true

  scope :search_member,     -> (member_id, friend_id) { where(follower_id: member_id, followed_id: friend_id).first }
  scope :search_friend,     -> (friend_id, member_id) { where(follower_id: friend_id, followed_id: member_id).first }

  def flush_cached
    # puts "clear cached #{self.follower.id}"
    # Rails.cache.delete([ self.follower, 'friend_count'])
    # Rails.cache.delete([ self.follower , 'following' ])
    # Rails.cache.delete([ self.follower.id, 'friend_active'])
    # Rails.cache.delete([ self.follower.id, 'your_request'])
    # Rails.cache.delete([ self.follower.id, 'friend_request'])
  end

  def self.friend_of_friend(friend)
    friend_id = friend[:friend_id]

    begin
      find_friend = Member.find(friend_id)
      friend_from_cached = find_friend.cached_get_friend_active
    rescue => e
      []
    end
  end

  def self.following_of_friend(friend)
    friend_id = friend[:friend_id]
    begin
      find_friend = Member.find(friend_id)
      following_from_cached = find_friend.cached_get_following
    rescue => e
      []
    end
  end

  def self.follower_of_friend(friend)
    friend_id = friend[:friend_id]

    begin
      find_friend = Member.find(friend_id)
      following_from_cached = find_friend.cached_get_follower
    rescue => e
      []
    end
  end


  def self.add_friend(friend)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    begin
      find_member = Member.find(member_id)
      find_friend = Member.find(friend_id)
      find_invitee = where(follower_id: member_id, followed_id: friend_id).having_status(:invitee).first
      find_used_friend = where(follower_id: friend_id, followed_id: member_id).having_status(:nofriend).first

      if find_invitee.present?
        find_invitee.update_attributes!(status: :friend)
        search_friend(friend_id, member_id).update_attributes!(status: :friend)
        status = :friend
        Activity.create_activity_friend( find_member, find_friend ,'BecomeFriend')
        Activity.create_activity_friend( find_friend, find_member ,'BecomeFriend')
      elsif find_used_friend
        # is_friend = false

        # if find_used_friend.following
        #   find_used_friend.update(status: :friend)
        #   is_friend = true
        # else
        #   find_used_friend.update(status: :invitee)
        # end
        find_used_friend.update(status: :invitee)
        create!(follower_id: member_id, followed_id: friend_id, status: :invite)
        status = :invite
      else
        create!(follower_id: member_id, followed_id: friend_id, status: :invite)
        create!(follower_id: friend_id, followed_id: member_id, status: :invitee)
        status = :invite
      end
      flush_cached_friend(member_id, friend_id)
      # AddFriendWorker.perform_async(member_id, friend_id)
      AddFriendWorker.perform_async(find_member, find_friend, {action: 'Invite'} )
      [find_friend, status]
    rescue  => e
      puts "error => #{e}"
    end
  end

  def self.add_or_un_close_friend(friend, status)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    begin
      search_member(member_id, friend_id).update_attributes!(close_friend: status)
      # flush_cached_friend_entity(member_id, friend_id) 
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
      find_friend = Member.find(friend_id)
      find_is_friend = where(follower_id: member_id, followed_id: friend_id, following: false).having_status(:friend).first

      if find_is_friend.present?
        find_is_friend.update(following: true)
      else
        create!(follower_id: member_id, followed_id: friend_id, status: :nofriend, following: true)
      end

      Activity.create_activity_friend( member, find_friend ,'Follow')

      Rails.cache.delete([ friend_id , 'follower' ])
      Rails.cache.delete([ member_id, 'following' ])
      flush_cached_friend(member_id, friend_id)

      find_friend
    rescue => e
      puts "error => #{e}"
    end
    
  end

  def self.unfollow(friend)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    find_following = where(follower_id: member_id, followed_id: friend_id, status: -1).first
    if find_following.present?
      Rails.cache.delete([ friend_id , 'follower' ])
      Rails.cache.delete([ member_id, 'following' ])
      flush_cached_friend(member_id, friend_id)

      find_following.destroy
    else
      false
    end
  end

  def self.unfriend(friend)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    # check_celebrity = Member.where("id IN (?)", [member_id, friend_id]).pluck(:member_type)

    find_member = search_member(member_id, friend_id)
    find_friend = search_friend(friend_id, member_id)

    if find_member && find_friend
      find_friend.destroy
      find_member.destroy
      flush_cached_friend(member_id, friend_id)
      Rails.cache.delete([ member_id, 'block_friend'])
    end
    [find_member, find_friend]
  end

  def self.accept_or_deny_freind(friend, accept)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]
    
    find_member = search_member(member_id, friend_id)
    find_friend = search_friend(friend_id, member_id)

    member = Member.find(member_id)
    friend = Member.find(friend_id)

    begin
      if accept
        active_status = true
        active_status = false if friend.friend_count >= friend.friend_limit

        search_member(member_id, friend_id).update_attributes!(active: active_status, status: :friend)
        search_friend(friend_id, member_id).update_attributes!(active: active_status, status: :friend)

        Activity.create_activity_friend( member, friend ,'BecomeFriend')
        Activity.create_activity_friend( friend, member ,'BecomeFriend')

        AddFriendWorker.new.perform(member, friend, { accept_friend: true, action: 'BecomeFriend' } )
      else
        find_member.destroy
        find_friend.destroy
      end
      flush_cached_friend(member_id, friend_id)
      [friend, :friend, active_status]
    rescue => e
      puts "error => #{e}"
      nil
    end
  end

  def self.block_or_unblock_friend(friend, type_block)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]
    begin
      search_member(member_id, friend_id).update_attributes!(block: type_block)
      search_friend(friend_id, member_id).update_attributes!(visible_poll: !type_block)
      flush_cached_friend(member_id, friend_id)
      Rails.cache.delete([ member_id, 'block_friend'])
      true
      # flush_cached_friend_entity(member_id, friend_id)
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
    
    search_member.each do |member|
      if my_friend.include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :friend]
      elsif your_request.include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :invite]
      elsif friend_request.include?(member.id)
        hash = Hash["add_friend_already" => true, "status" => :invitee]
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

  def self.flush_cached_friend(member_id, friend_id)
    Rails.cache.delete([ member_id, 'friend_active'])
    Rails.cache.delete([ member_id, 'your_request'])
    Rails.cache.delete([ member_id, 'friend_request'])

    Rails.cache.delete([ friend_id, 'friend_active'])
    Rails.cache.delete([ friend_id, 'your_request'])
    Rails.cache.delete([ friend_id, 'friend_request'])

    Rails.cache.delete(['user', member_id, 'relate', 'member', friend_id])
    Rails.cache.delete(['user', friend_id, 'relate', 'member', member_id])
  end

  def self.flush_cached_friend_entity(member_id, friend_id)
    Rails.cache.delete(['user', member_id, 'friend_entity_with', friend_id])
  end

end
