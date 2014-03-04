class Friend < ActiveRecord::Base
  include FriendsHelper

  belongs_to :follower, class_name: "Member"
  belongs_to :followed, class_name: "Member"

  validates :follower_id, presence: true
  validates :followed_id, presence: true

  scope :search_member, -> (member_id, friend_id) { where(follower_id: member_id, followed_id: friend_id).first }
  scope :search_friend, -> (friend_id, member_id) { where(follower_id: friend_id, followed_id: member_id).first }

  def self.add_friend(friend)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    begin
      find_friend = Member.find(friend_id)
      find_invitee = where(follower_id: member_id, followed_id: friend_id).having_status(:invitee).first
      
      if find_invitee.present?
        find_invitee.update_attributes!(status: :friend)
        search_friend(friend_id, member_id).update_attributes!(status: :friend)
        status = :friend
      else
        create!(follower_id: member_id, followed_id: friend_id, status: :invite)
        create!(follower_id: friend_id, followed_id: member_id, status: :invitee)
        status = :invite
      end
      [find_friend, status]
    rescue  => e
      puts "error => #{e}"
    end
  end

  def self.add_celebrity(friend)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    begin
      find_friend = Member.find(friend_id)
      create!(follower_id: member_id, followed_id: friend_id, status: :friend)
      find_friend
    rescue => e
      puts "error => #{e}"
    end
    
  end

  def self.unfriend(friend)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]

    find_member = search_member(member_id, friend_id)
    find_friend = search_friend(friend_id, member_id)

    if find_friend.present? && find_member.present?
      find_friend.destroy
      find_member.destroy
    end
  end

  def self.accept_or_deny_freind(friend, accept)
    friend_id = friend[:friend_id]
    member_id = friend[:member_id]
    
    find_member = search_member(member_id, friend_id)
    find_friend = search_friend(friend_id, member_id)

    friend = Member.find(friend_id)

    begin
      if accept
        active_status = true
        active_status = false if friend.friend_count >= friend.friend_limit

        search_member(member_id, friend_id).update_attributes!(active: active_status, status: :friend)
        search_friend(friend_id, member_id).update_attributes!(active: active_status, status: :friend)
      else
        find_member.destroy
        find_friend.destroy
      end
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
    rescue => e
      puts "error => #{e}"
      nil
    end
  end

  # def self.add_friend?(member_id, friend_list)
  #   check_friend_list = []
  #   friend_list.each do |friend|
  #     if where(follower_id: member_id, followed_id: friend.id).having_status(:friend).present?
  #       check_friend_list << Hash["add_friend_already" => true, "status" => :friend]
  #     elsif where(follower_id: member_id, followed_id: friend.id).having_status(:invite).present?
  #       check_friend_list << Hash["add_friend_already" => true, "status" => :invite]
  #     elsif where(follower_id: member_id, followed_id: friend.id).having_status(:invitee).present?
  #       check_friend_list << Hash["add_friend_already" => true, "status" => :invitee]
  #     else
  #       check_friend_list << Hash["add_friend_already" => false, "status" => :nofriend]
  #     end
  #   end
  #   check_friend_list
  # end

  def self.add_friend?(member_id, search_member)
    check_my_friend = []
    search_member_ids = search_member.map(&:id)
    my_friend = where("follower_id = ? AND followed_id IN (?)", member_id, search_member_ids)
    # puts "my_friend => #{my_friend}"
    my_friend_ids = my_friend.collect{|friend| [friend.followed_id, friend] }
    # puts "my friend ids => #{my_friend_ids}"
    search_member_ids.each do |member_id|
      @add_friend = nil
      my_friend_ids.each do |friend|
        if friend.first == member_id
          @add_friend = Hash["add_friend_already" => true, "status" => friend.last.status_text ]
        end
      end

      unless @add_friend.nil?
        check_my_friend << @add_friend
      else
        check_my_friend << Hash["add_friend_already" => false, "status" => :nofriend ]
      end
    end
    check_my_friend
  end

end
