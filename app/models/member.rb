class Member < ActiveRecord::Base
  # has_paper_trail
  
  mount_uploader :avatar, MemberUploader
  mount_uploader :cover, MemberUploader

  attr_accessor :fullname
  
  cattr_accessor :current_member

  include MemberHelper

  has_one :member_invite_code, dependent: :destroy

  has_many :watcheds, dependent: :destroy

  has_many :apn_devices, class_name: 'Apn::Device', dependent: :destroy

  has_many :sent_notifies, class_name: 'NotifyLog', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_notifies, -> { includes :sender }, class_name: 'NotifyLog',  foreign_key: 'recipient_id', dependent: :destroy

  belongs_to :province, inverse_of: :members

  has_many :follower , -> { where("following = 't' AND status != 1") }, foreign_key: "followed_id", class_name: "Friend"
  has_many :get_follower, through: :follower, source: :follower

  has_many :following, -> { where("following = 't' AND status != 1") }, foreign_key: "follower_id", class_name: "Friend", dependent: :destroy
  has_many :get_following, -> { where('members.member_type = 1 OR members.member_type = 2') } ,through: :following, source: :followed
  
  has_many :hidden_polls, dependent: :destroy

  has_many :history_views, dependent: :destroy

  has_many :history_votes, dependent: :destroy

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members, source: :group

  has_many :group_active, -> { where("group_members.active = ?", true) } , dependent: :destroy, class_name: "GroupMember"
  has_many :get_group_active , through: :group_active, source: :group

  has_many :group_inactive, -> { where("group_members.active = ?", false) } , dependent: :destroy, class_name: "GroupMember"
  has_many :get_group_inactive , through: :group_inactive, source: :group


  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members, source: :group, dependent: :destroy

  has_many :your_request, -> { where(status: 0, active: true) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_your_request, through: :your_request, source: :followed

  has_many :friend_active, -> { where(status: 1, active: true) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_active, through: :friend_active ,source: :followed

  has_many :friend_inactive, -> { where(status: 1, active: false) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_inactive, through: :friend_inactive, source: :followed

  has_many :friend_request, -> { where(status: 2, active: true) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_request, through: :friend_request, source: :followed

  has_many :whitish_friend, -> { where(active: true, mute: false, visible_poll: true).having_status(:friend) }, class_name: "Friend", foreign_key: "follower_id"
  
  has_many :get_my_poll, -> { where("polls.series = ?", false).limit(LIMIT_POLL) }, class_name: "Poll"
  
  has_many :poll_members, dependent: :destroy
  has_many :polls, through: :poll_members, source: :poll

  has_many :lucky_campaign, -> { where("campaign_members.luck = ? AND campaign_members.redeem = ?", true, false) }, class_name: "CampaignMember"
  has_many :get_lucky_campaign, through: :lucky_campaign, source: :campaign

  has_many :campaigns, dependent: :destroy

  has_many :campaign_members, dependent: :destroy, class_name: "CampaignMember"
  has_many :have_campaigns, through: :campaign_members, source: :campaign

  has_many :share_polls, dependent: :destroy
  has_many :recurrings, dependent: :destroy
  
  has_many :poll_series
  before_create :set_friend_limit
  
  has_many :providers, dependent: :destroy

  has_many :member_report_polls, dependent: :destroy
  has_many :poll_reports, through: :member_report_polls, source: :poll

  # after_create :set_follow_pollios


  scope :citizen,   -> { where(member_type: 0) }
  scope :celebrity, -> { where(member_type: 1) }

  validates :email, presence: true, :uniqueness => { :case_sensitive => false }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  # validates :username , :uniqueness => { :case_sensitive => true }

  LIMIT_POLL = 10
  self.per_page = 20
  FRIEND_LIMIT = 500

  rails_admin do 

    configure :new_avatar do
      pretty_value do
        bindings[:view].tag(:img, { :src => Member.check_image_avatar(bindings[:object].avatar), :class => 'img-polaroid', width: "50px", height: "50px"})
      end
    end

    list do
      filters [:gender, :member_type]
      field :id
      field :new_avatar
      field :fullname
      field :email
      field :gender do
        filterable true
        queryable false
      end
      field :member_type do
        filterable true
        queryable false
      end
      field :created_at
    end

    configure :follower do
      visible(false)
    end

    create do
      field :email
      field :fullname
      field :username
      field :gender
      field :member_type
      field :friend_limit
      field :birthday
      field :province
      field :avatar
      field :key_color
    end

    update do
      field :email do
       read_only true
      end
      field :fullname
      field :username
      field :gender
      field :member_type
      field :friend_limit
      field :birthday
      field :province
      field :avatar, :carrierwave
      field :cover, :carrierwave
      field :key_color

    end

    edit do
      field :fullname
      field :username
      field :gender
      field :member_type
      field :friend_limit
      field :birthday
      field :province
      field :avatar, :carrierwave
      field :cover, :carrierwave
      field :key_color
    end

    show do
      include_all_fields
      exclude_fields :avatar
    end

  end

  def new_avatar
    avatar.url(:thumbnail)
  end

  def get_activity_count
    find_activify = Activity.find_by(member_id: id)

    find_activify.present? ? find_activify.items.count : 0
  end

  def Member.check_image_avatar(avatar)
    for_campare_url_image = /\.(gif|jpg|png)\z/i
    if for_campare_url_image.match(avatar.model[:avatar]).present?
      if avatar.model[:avatar].start_with?('http')
        avatar.model[:avatar]
      else
        avatar.url(:thumbnail)
      end
    else
      if avatar.present?
        avatar.model[:avatar] + ".jpg"
      else
        avatar.url(:thumbnail)
      end
    end
  end

  def get_sentai_id
    providers.where(name: 'sentai').first.pid    
  end

  def get_name
    fullname.presence || ""
  end

  def get_username
    username.presence || ""
  end

  def get_cover_image
    cover.present? ? cover.url(:cover) : ""
  end

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
      "my_poll" => cached_my_poll.count,
      "my_vote" => cached_my_voted.count,
      "my_watched" => cached_watched.count,
      "friend" => cached_get_friend_active.count,
      "group" => cached_get_group_active.count,
      "activity" => get_activity_count,
      "following" => cached_get_following.count,
      "direct_msg" => 0,
      "status" => 0
    }
  end

  def cached_poll_friend_count(member)
    Rails.cache.fetch([ self.id, 'poll_count']) do
      FriendPollInProfile.new(member, self, {}).poll_friend_count
    end
  end

  def cached_voted_friend_count(member)
    Rails.cache.fetch([ self.id, 'vote_count']) do
      FriendPollInProfile.new(member, self, {}).vote_friend_count
    end
  end

  def cached_groups_friend_count(member)
    # Rails.cache.fetch([ self.id, 'group_count']) do
    #   FriendPollInProfile.new(member, self, {}).group_friend_count
    # end
    FriendPollInProfile.new(member, self, {}).group_friend_count
  end

  def cached_watched_friend_count(member)
    Rails.cache.fetch([ self.id, 'friend_count']) do
      FriendPollInProfile.new(member, self, {}).watched_friend_count
    end
  end

  def cached_shared_poll
    Rails.cache.fetch([ self, "shared"]) { share_polls.to_a }
  end

  def cached_report_poll
    Rails.cache.fetch([ self, 'report']) { poll_reports.to_a }
  end

  # def cached_poll_count
  #   Rails.cache.fetch([self.id, 'poll_count']) do
  #     polls.count
  #   end
  # end

  # def cached_poll_member_count
  #   Rails.cache.fetch([self.id, 'poll_member']) do
  #     Poll.where(member_id: id).count
  #   end
  # end

  # def cached_voted_count
  #   Rails.cache.fetch([self.id, 'vote_count']) do
  #     history_votes.where(poll_series_id: 0).count
  #   end
  # end


  def cached_my_poll
    Rails.cache.fetch([self.id, 'my_poll']) do
      Poll.where(member_id: id).to_a
    end
  end

  def cached_my_voted
    Rails.cache.fetch([self, 'my_voted']) do
      HistoryVote.where("member_id = #{id} AND poll_series_id = 0").to_a
    end
  end

  def cached_watched
    Rails.cache.fetch([ self, "watcheds" ]) do
      watcheds.to_a
    end
  end

  def cached_get_following
    Rails.cache.fetch([self.id, 'following'], :expires_in => 1.hours) do
      get_following.to_a
    end
  end

  def cached_get_follower
    Rails.cache.fetch([self.id, 'follower'], :expires_in => 1.hours) do
      get_follower.to_a
    end
  end

  def cached_get_friend_active
    Rails.cache.fetch([self.id, 'friend_active'], :expires_in => 1.hours) do
      get_friend_active.to_a
    end
  end

  def cached_get_your_request
    Rails.cache.fetch([self.id, 'your_request']) do
      get_your_request.to_a
    end
  end

  def cached_get_friend_request
    Rails.cache.fetch([self.id, 'friend_request']) do
      get_friend_request.to_a
    end
  end

  def cached_get_group_active
    Rails.cache.fetch([self.id, 'group_active']) do
      get_group_active.to_a
    end
  end

  def campaigns_available
    campaign = campaigns.includes(:poll).order("name desc")
    campaign.delete_if{|x| x.poll.present? }
  end

  def list_voted?(history_voted, poll_id)
    history_voted.each do |poll_choice|
      if poll_choice.first == poll_id
        return Hash["voted" => true, "choice_id" => poll_choice[1], "answer" => poll_choice[2], "vote" => poll_choice[4]]
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

  def check_gender
    if gender.present? && gender != 0
      gender
    else
      "undefined"
    end
  end

  def self.update_profile(response)
    fullname = response["name"]
    sentai_fullname = response["fullname"]
    username = response["username"]
    email = response["email"]
    avatar = response["avatar_thumbnail"]
    birthday = response["birthday"]
    gender = response["gender"]
    province_id = response["province"]["id"]

    find_member = where(email: email).first
    if find_member.present? 
      find_member.update_attributes!(fullname: sentai_fullname, avatar: avatar, birthday: birthday, username: username, gender: gender, province_id: province_id)
      return find_member
    end
  end


  ########### Search Member #############

  def self.search_member(params)
    if params[:q].present?
      where("id != ? AND (email LIKE ? OR fullname LIKE ? OR username LIKE ?)", params[:member_id].to_i ,"%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%")
    else
      nil
    end
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


  def cancel_or_leave_group(group_id, type)
    find_group_member = group_members.where(group_id: group_id).first
    if find_group_member
      find_group_member.group.decrement!(:member_count) if type == "L" 
      find_group_member.destroy
    end
    cached_flush_active_group
  end

  def delete_group(group_id)
    find_group_member = group_members.where(group_id: group_id).first
    if find_group_member
      find_group_member.group.destroy if find_group_member.is_master
    end
    cached_flush_active_group
  end

  def cached_flush_active_group
    Rails.cache.delete([id, 'group_active'])
    # Rails.cache.delete([id, 'group_count'])  
  end

  def check_share_poll?(poll_id)
    share_poll_ids = share_polls.pluck(:poll_id)
    if share_poll_ids.include?(poll_id)
      Hash["shared" => true]
      else
      Hash["shared" => false]
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

  def get_birthday
    birthday.present? ? birthday : ""
  end

  def get_token(provider_name)
    find_provider = providers.find_by(name: provider_name)
    find_provider.present? ? find_provider.token : ""
  end

  def get_template
    Template.where(member_id: id).first
  end

  # def self.cached_member_of_poll(current_member, member_of_poll)
  #   MemberSerializer.new(member_of_poll, serializer_options: { current_member: current_member }).as_json
  # end

  def self.serializer_member_detail(current_member, member_of_poll)
    member_as_json = serializer_member_hash( cached_member(member_of_poll))
    member_hash = member_as_json.merge({ "status" => entity_info(current_member, member_of_poll)})
    member_hash
  end

  def self.entity_info(current_member, member_of_poll)
    member_of_poll.is_friend(current_member)
  end

  def self.cached_member(member)
    Rails.cache.fetch(member) { member }
  end

  def self.serializer_member_hash(member)
    V5::MemberSerializer.new(member).as_json()
  end

  def self.cached_friend_entity(user, friend)
    Rails.cache.fetch(['user', user.id, 'friend_entity_with', friend.id]) do
      FriendSerializer.new(friend, serializer_options: { user: user} ).as_json
    end
  end

  def check_friend_entity(user)
    find_friend = Friend.where("(follower_id = ? AND followed_id = ? AND status = ?) " \
                        "OR (follower_id = ? AND followed_id = ? AND status = ?)", 
                        user.id, id, 1,
                        user.id, id, -1).first

    if find_friend.present?
      {
        close_friend: find_friend.close_friend,
        block_friend: find_friend.block
      }
    else
      {
        close_friend: "",
        block_friend: ""
      }
    end
  end

  def as_json options={}
   {
      member_id: id,
      type: member_type_text,
      name: fullname,
      username: username,
      email: email,
      avatar: detect_image(avatar),
      key_color: get_key_color,
      cover: get_cover_image,
      description: get_description
   }
  end

  def is_friend(user_obj)
    my_friend = user_obj.cached_get_friend_active.map(&:id)
    your_request = user_obj.cached_get_your_request.map(&:id)
    friend_request = user_obj.cached_get_friend_request.map(&:id)
    my_following = user_obj.cached_get_following.map(&:id)
    
    if my_friend.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :friend]
    elsif your_request.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :invite]
    elsif friend_request.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :invitee]
    else
      hash = Hash["add_friend_already" => false, "status" => :nofriend]
    end

    if celebrity? || brand?
      my_following.include?(id) ? hash.merge!({"following" => true }) : hash.merge!({"following" => false })
    else
      hash.merge!({"following" => "" })
    end
    hash
  end

  def get_key_color
    key_color.present? ? key_color : ""  
  end

  def get_description
    description.present? ? description : ""
  end

  def get_avatar
    detect_image(avatar)
  end

  def self.update_avatar(current_member, file_avatar)
    member = current_member
    current_avatar = member.avatar.identifier
    if current_avatar.present?
      begin
        if current_avatar.start_with?('https://') || current_avatar.start_with?('http://')
          member.remove_avatar!
          member.save!
        end
      end
    end
    @member = Member.find(current_member.id)
    @member.update(avatar: file_avatar)
  end


  def detect_image(avatar)
    new_avatar = ""
    if avatar.present?
      if avatar.identifier.start_with?('http://')
        new_avatar = avatar.identifier
      elsif avatar.identifier.start_with?('https://') #facebook
        new_avatar = avatar.identifier
      else
        new_avatar = avatar.url(:thumbnail)
      end
    end
    new_avatar
  end

end