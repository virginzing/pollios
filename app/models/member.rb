class Member < ActiveRecord::Base
  include MemberHelper
  belongs_to :province
  
  has_many :apn_devices,  :class_name => 'APN::Device', :dependent => :destroy
  has_many :hidden_polls, dependent: :destroy

  has_many :history_views, dependent: :destroy

  has_many :history_votes, dependent: :destroy

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members, source: :group

  has_many :group_active, -> { where("group_members.active = ?", true) } , dependent: :destroy, class_name: "GroupMember"
  has_many :get_group_active , through: :group_active, source: :group

  has_many :group_inactive, -> { where("group_members.active = ?", false) } , dependent: :destroy, class_name: "GroupMember"
  has_many :get_group_inactive , through: :group_inactive, source: :group

  has_many :reverse_friend ,foreign_key: "followed_id", class_name: "Friend"
  has_many :following, through: :reverse_friend, source: :follower

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members, source: :group, dependent: :destroy

  has_many :your_request, -> { where(status: 0, active: true) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_your_request, through: :your_request, source: :followed

  has_many :friend_active, -> { where(status: 1, active: true) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_active, through: :friend_active, source: :followed

  has_many :friend_inactive, -> { where(status: 1, active: false) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_inactive, through: :friend_inactive, source: :followed

  has_many :friend_request, -> { where(status: 2, active: true) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_request, through: :friend_request, source: :followed

  has_many :whitish_friend, -> { where(active: true, mute: false, visible_poll: true).having_status(:friend) }, class_name: "Friend", foreign_key: "follower_id"
  
  has_many :get_my_poll, -> { where("polls.series = ?", false) }, class_name: "Poll"
  has_many :poll_members, dependent: :destroy
  has_many :polls, through: :poll_members, source: :poll

  has_many :campaigns, dependent: :destroy

  has_many :campaign_members, dependent: :destroy, class_name: "CampaignMember"
  has_many :have_campaigns, through: :campaign_members, source: :campaign

  has_many :recurrings, dependent: :destroy
  
  has_many :poll_series
  before_create :set_friend_limit

  scope :citizen,   -> { where(member_type: 0).order("username desc") }
  scope :celebrity, -> { where(member_type: 1).order("username desc") }

  self.per_page = 20
  FRIEND_LIMIT = 500

  def set_friend_limit
    self.friend_limit = FRIEND_LIMIT
  end

  def get_recurring_available
    list_recurring = []
    recurrings.includes(:polls).each do |rec|
      unless rec.polls.present?
        list_recurring << rec
      end
    end
    list_recurring
  end

  def get_stats_all
    {
      "my_poll" => Poll.unscoped.where("member_id = ? AND series = ?", id, false).count,
      "my_vote" => history_votes.where(poll_series_id: 0).count,
      "direct_msg" => 0,
      "status" => 0
    }
  end

  def list_voted?(history_voted, poll_id)
    history_voted.each do |poll_choice|
      if poll_choice.first == poll_id
        return Hash["voted" => true, "choice_id" => poll_choice[1]]
      end
    end
    Hash["voted" => false]
  end

  def list_voted_questionnaire?(history_voted, poll_series_id)
    history_voted.each do |poll|
      if poll.last == poll_series_id
        return Hash["voted" => true]
      end
    end
    Hash["voted" => false]
  end

  def list_viewed?(history_viewed, poll_id)
    history_viewed.include?(poll_id)
  end

  def viewed?(poll_id)
    find_viewed = history_views.where(poll_id: poll_id).first
    find_viewed.present?
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
    birthday = response["birthday"]
    gender = response["gender"]
    province_id = response["province"]["id"]

    member = where(sentai_id: sentai_id.to_s, provider: "sentai").first_or_initialize do |m|
      m.sentai_id = sentai_id.to_s
      m.sentai_name = sentai_fullname
      m.username = username
      m.email = email
      m.avatar = avatar
      m.token = token
      m.birthday = birthday
      m.gender = gender
      m.province_id = province_id
      m.provider = "sentai"
      m.save
    end
    
    member.update_attributes!(username: username, sentai_name: sentai_fullname, avatar: avatar, token: token, gender: gender, province_id: province_id, birthday: birthday) unless member.new_record?
    return member
  end

  def self.update_profile(response)
    sentai_name = response["name"]
    sentai_fullname = response["fullname"]
    username = response["username"]
    sentai_id = response["sentai_id"]
    email = response["email"]
    avatar = response["avatar_thumbnail"]
    birthday = response["birthday"]
    gender = response["gender"]
    province_id = response["province"]["id"]

    find_member = where(sentai_id: sentai_id.to_s).first
    if find_member.present? 
      find_member.update_attributes!(sentai_name: sentai_fullname, avatar: avatar, email: email, birthday: birthday, username: username, gender: gender, province_id: province_id)
      return find_member
    end
  end

  def self.facebook(response)
    fb_id = response["id"]
    fb_fullname = response["name"]
    username = response["username"]
    email = response["email"]
    avatar = response["user_photo"]
    birthday = response["birthday"]
    gender = response["gender"]
    province_id = response["province_id"]

    member = where(sentai_id: fb_id, provider: "facebook").first_or_initialize do |m|
      m.sentai_id = fb_id
      m.sentai_name = fb_fullname
      m.username = username
      m.email = email
      m.avatar = avatar
      m.birthday = birthday
      m.gender = gender
      m.province_id = province_id
      m.provider = "facebook"
      m.save
    end
    
    member.update_attributes!(username: username, sentai_name: fb_fullname, avatar: avatar, gender: gender, province_id: province_id, birthday: birthday) unless member.new_record?
    return member
  end

  ########### Search Member #############

  def self.search_member(params)
    where("email = ? OR username = ?", params, params).first
  end

  ################ Friend ###############
  
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

  def get_province
    if province.present?
      {
        "id" => province.id,
        "name" => province.name
      }
    else
      ""
    end
  end


  def as_json options={}
   {
      id: id,
      type: member_type_text,
      name: sentai_name,
      username: username,
      email: email,
      avatar: avatar.present? ? avatar : "No Image"
   }
  end


end