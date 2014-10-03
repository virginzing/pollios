class Member < ActiveRecord::Base

  serialize :interests, Array
  # has_paper_trail
  include PgSearch
  # multisearchable :against => [:fullname, :username, :email]
  pg_search_scope :searchable_member, :against => [:fullname, :username, :email],
                  :using => { 
                    :tsearch => { :prefix => true, :dictionary => "english" },
                    :trigram => { :threshold => 0.5 }
                  }

  mount_uploader :avatar, MemberUploader
  mount_uploader :cover, MemberUploader

  store_accessor :setting
  
  cattr_accessor :current_member, :reported_polls, :shared_polls, :viewed_polls, :voted_polls, :list_friend_block, :list_friend_active,
                  :list_your_request, :list_friend_request, :list_friend_following, :list_group_active, :watched_polls

  include MemberHelper

  has_many :member_invite_codes, dependent: :destroy
  has_many :member_un_recomments, dependent: :destroy
  has_many :history_view_questionnaires, dependent: :destroy

  has_one :company, dependent: :destroy

  has_many :comments, dependent: :destroy
  has_many :history_purchases, dependent: :destroy

  has_many :watcheds, dependent: :destroy

  has_many :apn_devices, class_name: 'Apn::Device', dependent: :destroy

  has_many :sent_notifies, class_name: 'NotifyLog', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_notifies, -> { includes :sender }, class_name: 'NotifyLog',  foreign_key: 'recipient_id', dependent: :destroy

  has_many :sent_reports, class_name: 'MemberReportMember', foreign_key: 'reporter_id', dependent: :destroy
  has_many :get_reportee, -> { includes :reporter }, class_name: 'MemberReportMember', foreign_key: 'reportee_id', dependent: :destroy

  # belongs_to :province, inverse_of: :members

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

  has_many :friend_active, -> { where(status: 1, active: true, block: false) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_active, through: :friend_active ,source: :followed

  has_many :friend_blocked, -> { where(status: 1, active: true, block: true) }, foreign_key: "follower_id", class_name: "Friend"
  has_many :get_friend_blocked, through: :friend_blocked ,source: :followed

  has_many :muted_by_friend, -> { where(mute: true) }, foreign_key: "followed_id", class_name: "Friend"
  has_many :get_muted_by_friend, through: :muted_by_friend, source: :follower

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

  has_many :request_codes, dependent: :destroy

  # after_create :set_follow_pollios


  scope :citizen,   -> { where(member_type: 0) }
  scope :celebrity, -> { where(member_type: 1) }

  validates :email, presence: true, :uniqueness => { :case_sensitive => false }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :username , :uniqueness => { :case_sensitive => false}, format: { with: /\A[a-zA-Z0-9_.]+\z/i, message: "only allows letters" }, :allow_blank => true , on: :update

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
      field :username
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
      field :description
      field :status_account
      field :point
      field :subscription
      field :bypass_invite
      field :approve_brand
      field :approve_company
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
      field :status_account
      field :report_count
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

  def is_admin_group(status)
    status ? "Admin" : "Member"
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

  def cached_block_friend_count(member)
    Rails.cache.fetch([ self.id, 'block_count']) do
      FriendPollInProfile.new(member, self, {}).block_friend_count
    end
  end

  def cached_shared_poll
    Rails.cache.fetch([ self, "shared"]) { share_polls.to_a }
  end

  def cached_report_poll
    Rails.cache.fetch([ self, 'report']) { poll_reports.to_a }
  end

  def cached_block_friend
    Rails.cache.fetch([self.id, 'block_friend']) do
      get_friend_blocked.to_a
    end
  end

  def my_vote_poll_ids
    Member.voted_polls.select{|e| e[3] == 0 }.collect{|e| e.first }
  end

  def cached_my_poll
    Rails.cache.fetch([self.id, 'my_poll']) do
      Poll.available.joins(:poll_members).includes(:member, :campaign, :choices)
        .where("polls.vote_all > 0")
        .where("(poll_members.member_id = #{self.id} AND poll_members.share_poll_of_id = 0) OR (polls.id IN (?) AND polls.member_id = #{self.id} AND poll_members.share_poll_of_id = 0)", my_vote_poll_ids).to_a
    end
  end

  def cached_my_questionnaire
    Rails.cache.fetch([self.id, 'my_questionnaire']) do
      PollSeries.where(member_id: id).to_a
    end
  end

  def cached_my_voted
    Rails.cache.fetch([self.id, 'my_voted']) do
      HistoryVote.joins(:member, :choice, :poll)
                  .select("history_votes.*, choices.answer as choice_answer, choices.vote as choice_vote, polls.show_result as display_result")
                  .where("history_votes.member_id = #{id} AND history_votes.poll_series_id = '0'")
                  .collect! { |voted| [voted.poll_id, voted.choice_id, voted.choice_answer, voted.poll_series_id, voted.choice_vote, voted.display_result] }.to_a
    end
  end

  def cached_watched
    Rails.cache.fetch([ self.id, "watcheds" ]) do
      Poll.joins(:member).available.joins(:watcheds).where("(watcheds.member_id = #{self.id} AND watcheds.poll_notify = 't')").to_a
    end
  end

  def cached_get_unrecomment
    Rails.cache.fetch([self.id, 'unrecomment']) do
      member_un_recomments.to_a
    end
  end

  def cached_get_following
    Rails.cache.fetch([self.id, 'following']) do
      get_following.to_a
    end
  end

  def cached_get_follower
    Rails.cache.fetch([self.id, 'follower']) do
      get_follower.to_a
    end
  end

  def cached_get_friend_active
    Rails.cache.fetch([self.id, 'friend_active']) do
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

  def cached_get_my_reward
    Rails.cache.fetch([self.id, 'reward']) do
      CampaignMember.where("member_id = #{id} AND luck = 't' AND redeem = 'f'").to_a
    end
  end

  def campaigns_available
    campaign = campaigns.includes(:poll).order("name desc")
    campaign.delete_if{|x| x.poll.present? }
  end

  def list_voted?(poll)
    history_voted = Member.voted_polls
    history_voted.each do |poll_choice|
      if poll_choice.first == poll.id

        choice_list ||= poll.cached_choices
        choice_voted = choice_list.select {|e| e.id == poll_choice[1] }.first.vote
        return Hash["voted" => true, "choice_id" => poll_choice[1], "answer" => poll_choice[2], "vote" => choice_voted]
      end
    end
    Hash["voted" => false]
  end

  def list_voted_questionnaire?(poll_series)
    history_voted = Member.voted_polls

    history_voted.each do |poll|
      if poll[3] == poll_series.id
        return Hash["voted" => true]
      end
    end
    Hash["voted" => false]
  end

  def list_viewed?(poll_id)
    history_viewed = Member.viewed_polls
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

    find_member = where(email: email).first
    if find_member.present? 
      find_member.update_attributes!(fullname: sentai_fullname, avatar: avatar, birthday: birthday, username: username, gender: gender)
      return find_member
    end
  end


  ########### Search Member #############

  def self.search_member(params)
    if params[:q].present?
      searchable_member(params[:q])
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
      find_group_member.group.decrement!(:member_count) if type == "L" && find_group_member.group.member_count > 0 
      find_group_member.destroy
    end
    cached_flush_active_group
    true
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
    province.present? ? province.value : ""
  end

  def get_birthday
    birthday.present? ? birthday.strftime("%b %d, %Y") : ""
  end

  def get_gender
    gender.present? ? gender.value : ""
  end

  def get_interests
    interests.present? ? interests.collect{|e| e.value } : ""
  end

  def get_salary
    salary.present? ? salary.value : ""
  end

  def get_token(provider_name)
    if provider_name.present?
      find_provider = providers.find_by(name: provider_name)
      find_provider.present? ? find_provider.token : ""
    else
      find_provider = providers.first
      find_provider.present? ? find_provider.token : ""
    end
  end

  def get_template
    Template.where(member_id: id).first
  end

  def get_anonymous_with_poll(poll)
    if poll.in_group_ids != '0'
      anonymous_group
    else
      if poll.public
        anonymous_public
      else
        anonymous_friend_following
      end
    end
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
    Rails.cache.fetch(member) do
      member.as_json
    end
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
      avatar: avatar.present? ? resize_avatar(avatar.url) : "",
      key_color: get_key_color,
      cover: cover.present? ? resize_cover(cover.url) : "",
      description: get_description,
   }
  end

  def resize_avatar(avatar_url)
    avatar_url.split("upload").insert(1, "upload/c_fill,h_180,w_180").sum
  end

  def resize_cover(cover_url)
    cover_url.split("upload").insert(1, "upload/c_fit,w_640").sum
  end

  def is_friend(user_obj)
    @my_friend ||= user_obj.cached_get_friend_active.map(&:id)
    @your_request ||= user_obj.cached_get_your_request.map(&:id)
    @friend_request ||= user_obj.cached_get_friend_request.map(&:id)
    @my_following ||= user_obj.cached_get_following.map(&:id)
    @block_friend ||= user_obj.cached_block_friend.map(&:id)

    if @my_friend.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :friend]
    elsif @your_request.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :invite]
    elsif @friend_request.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :invitee]
    elsif @block_friend.include?(id)
      hash = Hash["add_friend_already" => true, "status" => :block]
    else
      hash = Hash["add_friend_already" => false, "status" => :nofriend]
    end

    if celebrity? || brand?
      @my_following.include?(id) ? hash.merge!({"following" => true }) : hash.merge!({"following" => false })
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

  def get_history_viewed
    @history_viewed = history_views.collect { |viewed| viewed.poll_id }
  end

  def get_request_code
    request_codes.first.present?
  end

  # def get_history_voted
  #   @history_voted = HistoryVote.joins(:member, :choice, :poll)
  #                               .select("history_votes.*, choices.answer as choice_answer, choices.vote as choice_vote")
  #                               .where("history_votes.member_id = #{id}")
  #                               .collect! { |voted| [voted.poll_id, voted.choice_id, voted.choice_answer, voted.poll_series_id, voted.choice_vote] }
  # end

end