class Member < ActiveRecord::Base

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members

  has_many :friends, foreign_key: "follower_id",  dependent: :destroy
  has_many :my_friends, through: :friends, source: :followed

  has_many :normally_friends, -> { where(status: 1) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :my_normally_friends, through: :normally_friends, source: :followed


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

  def add_friend(friend)
    friend_id = friend[:friend_id]
    begin
      status = 1 #normal 
      find_friend = Member.find(friend_id)

      unless find_friend.public_member
        status = 0 #pending , -1 #block
      end
      friends.create!(followed_id: find_friend.id, status: status)
      find_friend.friends.create!(followed_id: id, status: status)
      find_friend
    rescue  => e
      puts "error => #{e}"
      nil
    end
  end

  def block_or_unblock_friend(friend, type)
    friend_id = friend[:friend_id]
    begin
      find_friend = friends.where(followed_id: friend_id).first
      puts "find => #{find_friend}"
      find_friend.update_attributes!(status: type)
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
        find_friend.update_attributes!(status: 1)
        Member.find(friend_id).friends.where(followed_id: id).first.update_attributes!(status: 1)
      else
        find_friend = friends.where(followed_id: friend_id).first.destroy
        Member.find(friend_id).friends.where(followed_id: id).first.destroy
      end
    rescue => e
      puts "error => #{e}"
      nil
    end
  end

  def self.search_member(params)
    where("email = ? OR username = ?", params, params).first
  end

end
