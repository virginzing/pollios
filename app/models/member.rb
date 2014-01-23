class Member < ActiveRecord::Base

  has_many :polls, dependent: :destroy

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members, source: :group, dependent: :destroy

  has_many :friends, foreign_key: "follower_id",  dependent: :destroy
  has_many :my_friends, through: :friends, source: :followed

  has_many :be_friends, -> { where(active: true) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_be_friends, through: :be_friends, source: :followed

  has_many :poll_of_friends, -> { where(active: true, mute: false, visible_poll: true) }, class_name: "Friend", foreign_key: "follower_id"

  def get_poll_friends
    list_friend = poll_of_friends.map(&:followed_id) << id
    Poll.where(member_id: list_friend)
  end

  ########### Authen Sentai #############

  def self.identify_access(response)
    sentai_id = response["sentai_id"]
    sentai_name = response["name"]
    sentai_fullname = response["fullname"]
    username = response["username"]
    token = response["token"]
    email = response["email"]
    avatar = response["avatar_thumbnail"]

    member = where(sentai_id: sentai_id.to_s).first_or_initialize do |member|
      member.sentai_id = sentai_id.to_s
      member.sentai_name = sentai_fullname
      member.username = username
      member.email = email
      member.avatar = avatar
      member.token = token
      member.save
    end
    
    member.update_attributes!(sentai_name: sentai_fullname, avatar: avatar, token: token) unless member.new_record?
    return member
  end

  ################ Friend ###############

  def add_friend(friend)
    friend_id = friend[:friend_id]
    begin
      active = true 
      find_friend = Member.find(friend_id)

      unless find_friend.public_id
        active = false #pending
      end
      friends.create!(followed_id: find_friend.id, active: active)
      find_friend.friends.create!(followed_id: id, active: active)
      [find_friend, active]
    rescue  => e
      puts "error => #{e}"
      nil
    end
  end

  def unfriend(friend_id)
    find_friend = friends.where(followed_id: friend_id).first
    if find_friend
      find_friend.destroy
      Member.find(friend_id).friends.where(followed_id: id).first.destroy
    end
  end

  def block_or_unblock_friend(friend, type_block)
    friend_id = friend[:friend_id]
    begin
      find_friend = friends.where(followed_id: friend_id).first
      find_friend.update_attributes!(block: type_block)
      Member.find(friend_id).friends.where(followed_id: id).first.update_attributes(visible_poll: false)
    rescue => e
      puts "error => #{e}"
      nil
    end
  end

  def mute_or_unmute_friend(friend, type_mute)
    friend_id = friend[:friend_id]
    begin
      find_friend = friends.where(followed_id: friend_id).first
      find_friend.update_attributes!(mute: type_mute)
    rescue => e
      puts "error => #{e}"
      nil
    end
  end

  def accept_or_deny_freind(friend, accept)
    friend_id = friend[:friend_id]
    begin
      if accept
        find_friend = friends.where(followed_id: friend_id).first
        puts "find => #{find_friend}"
        find_friend.update_attributes!(active: true)
        Member.find(friend_id).friends.where(followed_id: id).first.update_attributes!(active: true)
      else
        find_friend = friends.where(followed_id: friend_id).first.destroy
        Member.find(friend_id).friends.where(followed_id: id).first.destroy
      end
    rescue => e
      puts "error => #{e}"
      nil
    end
  end

  def add_friend_already(friend)
    return friends.where(followed_id: friend.id).present?
  end

  def self.search_member(params)
    where("email = ? OR username = ?", params, params).first
  end

  ################ Group ###############

  def create_group(group)
    friend_id = group[:friend_id] # ex. "1,2,3"
    name_group = group[:name]
    photo_group = group[:photo_group]

    begin
      list_friend = friend_id.split(",").collect{ |friend_id| friend_id.to_i } if friend_id.present?
      @new_group = groups.create!(name: name_group, photo_group: photo_group)

      if list_friend.present? && @new_group.present? # add friend to group when iOS send parameter friend_id and created group already.
        add_friends_to_group(list_friend)
      end
      @new_group
    rescue => e
      puts "error => #{e}"
      nil
    end
  end

  def add_friends_to_group(list_friend, option = {})
    group_id = option[:group_id] || @new_group.id
    member_in_group = Group.check_member_in_group(list_friend, group_id)

    if member_in_group.count > 0
      member_in_group.each do |friend_id|
        find_friend = Member.find_by(id: friend_id)
        if find_friend
          @group_member = GroupMember.create!(member_id: friend_id, group_id: group_id, is_master: false, invite_id: id, active: find_friend.group_active)
        end
      end
      @group_member.group
    end
  end

  def accept_group(group_id)
    find_group_member = group_members.where(group_id: group_id).first
    if find_group_member
      find_group_member.update_attributes!(active: true)
    end
  end

  def deny_or_leave_group(group_id)
    find_group_member = group_members.where(group_id: group_id).first
    if find_group_member
      find_group_member.destroy
    end
  end

  def delete_group(group_id)
    find_group_member = group_members.where(group_id: group_id).first
    if find_group_member
      find_group_member.group.destroy if find_group_member.is_master
    end
  end

  ################ Poll ###############

  def create_poll(poll)
    title = poll[:title]
    expire_date = poll[:expire_date]
    choices = poll[:choices]
    group_id = poll[:group_id]

    convert_expire_date = Date.current() + expire_date.to_i.days
    @poll = polls.create(title: title, expire_date: convert_expire_date, group_id: group_id)

    if @poll.valid?
      puts "create choices"
      @poll.create_choices(choices)
    end
    @poll
  end

  def vote_poll(poll)
    poll_id = poll[:poll_id]
    choice_id = poll[:choice_id]
  
    begin
      find_poll = Poll.find(poll_id)
      find_choice = find_poll.choices.where(id: choice_id).first
      if find_choice && find_poll
        find_poll.increment!(:vote_all)
        find_choice.increment!(:vote)
      end
    rescue => e
      puts "error => #{e}"
      nil
    end    
  end


end