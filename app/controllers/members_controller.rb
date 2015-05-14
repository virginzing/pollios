include MemberCoverPreset

class MembersController < ApplicationController
  include SymbolHash

  skip_before_action :verify_authenticity_token
  before_action :set_current_member, only: [:special_code, :invite_fb_user, :invite_user_via_email, :device_token, :setting_default, :unrecomment, :recommendations, :recommended_facebook, :recommended_groups, :recommended_official, :send_request_code, :public_id, :list_block, :report, :activate, :all_request, :my_profile, :activity, :detail_friend, :stats, :update_profile, :notify, :add_to_group_at_invite]
  # before_action :history_voted_viewed, only: [:detail_friend]
  before_action :compress_gzip, only: [:recommended_facebook, :activity, :detail_friend, :notify, :all_request, :recommendations, :recommended_groups, :recommended_official]
  before_action :signed_user, only: [:account_setting, :index, :profile, :update_group, :delete_avatar, :delete_cover, :delete_photo_group]

  before_action :load_resource_poll_feed, only: [:detail_friend, :my_profile]

  before_action :set_company, only: [:account_setting, :profile, :delete_photo_group], :if => :only_company
  before_action :find_group, only: [:account_setting, :profile, :delete_photo_group], :if => :only_company

  expose(:list_friend) { current_member.friend_active.pluck(:followed_id) }
  expose(:friend_request) { current_member.get_your_request.pluck(:id) }
  expose(:members) { |default| default.paginate(page: params[:page]) }
  expose(:member) { @current_member }
  expose(:share_poll_ids) { @current_member.cached_shared_poll.map(&:poll_id) }
  expose(:hash_member_count) { @hash_member_count }

  respond_to :json

  def recommendations
    init_list_friend = Member::ListFriend.new(@current_member)

    @init_recommendation = Recommendation.new(@current_member)
    @recommendations_official = @init_recommendation.get_recommendations_official.sample(2)
    @group_recomment = @init_recommendation.get_group.sample(2)
    @hash_member_count = @init_recommendation.hash_member_count

    @people_you_may_know = @init_recommendation.get_people_you_may_know.sample(20)
    @recommendations_follower = @init_recommendation.get_follower_recommendations.sample(2) if @current_member.celebrity?
    @facebook = @init_recommendation.get_member_using_facebook.sample(2)
  end

  def recommended_groups
    @init_recommendation = Recommendation.new(@current_member)
    @group_recomment = @init_recommendation.get_group
    @hash_member_count = @init_recommendation.hash_member_count
  end

  def recommended_official
    @init_recommendation = Recommendation.new(@current_member)
    @recommendations_official = @init_recommendation.get_recommendations_official
  end

  def recommended_facebook
    @init_recommendation = Recommendation.new(@current_member)
    @recommendations_facebook = @init_recommendation.get_member_using_facebook
  end

  def special_code
    @special_code = true
    code = params[:code]
    @special_code = SpecialQrcode.find_by(code: code)

    unless @special_code.present?
      @special_code = false
      render status: :not_found
    else
      @member_from_special_qrcode = Member.cached_find(@special_code.info["member_id"])
      init_list_friend_of_member ||= Member::ListFriend.new(@current_member)
      @is_friend = Friend.check_add_friend?(@current_member, [@member_from_special_qrcode], init_list_friend_of_member.check_is_friend)
    end
  end

  def list_members
    respond_with Member.limit(2), root: false
  end

  def invite_user_via_email
    init_invite_user = InviteUser.new(@current_member, params[:list_email])
    @invite_user_via_email = init_invite_user.create_list_invite
  end

  def invite_fb_user
    init_invite_fb_user = InviteFbUser.new(@current_member, params[:list_fb_id])
    @invite_fb_user = init_invite_fb_user.invite_all
  end

  def account_setting
    
  end

  def unrecomment
    friend_id = params[:friend_id]
    respond_to do |format|
      if friend_id.present?
        @current_member.member_un_recomments.where(unrecomment_id: friend_id).first_or_create! do |m|
          m.member_id = @current_member.id
          m.unrecomment_id = friend_id
          m.save
          Rails.cache.delete([ @current_member.id , 'unrecomment' ])
        end
        format.json { render json: Hash["response_status" => "OK", "response_message" => "Success"] }  
      else
        format.json { render json: Hash["response_status" => "ERROR", "response_message" => "Fail"] }
      end
    end
  end

  def detail_friend
    @find_friend = Member.find(params[:friend_id])
    poll = @find_friend.polls.includes(:member, :campaign)
    @poll_series, @poll_nonseries, @next_cursor = Poll.split_poll(poll)
    @is_friend = Friend.add_friend?(@current_member, [@find_friend]) if @find_friend.present?
  end

  def verify_email
    @response = Authenticate::Sentai.verify_email(verify_email_params)
    puts "response => #{@response}"
    if @response["response_status"] == "OK"
      @member = Member.find_by(email: verify_email_params[:email])
      @verify_email = true
    else
      @verify_email = false
    end
  end

  def device_token
    @device_token = ApnDevice.check_device?(@current_member, params[:device_token])
  end

  def profile
    @poll_latest_list = Poll.where(member_id: @current_member.id, series: false).order("created_at desc").limit(5)
  end

  def public_id
    begin
      @current_member = @current_member.update!(public_id: params[:public_id])
    rescue ActiveRecord::RecordInvalid => invalid
      @current_member = nil
      @error_message = invalid.record.errors.messages[:public_id][0]
      render status: :unprocessable_entity
    end
  end

  def delete_avatar
    Member.transaction do
      begin
        @current_member.remove_avatar!
        @current_member.save
        flash[:success] = "Delete avatar successfully."
      rescue => e
        flash[:error] = e.message
      end
      respond_to do |format|
        format.html { redirect_to account_setting_path }
      end
    end
  end

  def delete_cover
    Member.transaction do
      begin
        @current_member.remove_cover!
        @current_member.save
        flash[:success] = "Delete cover successfully."
      rescue => e
        flash[:error] = e.message
      end
      respond_to do |format|
        format.html { redirect_to account_setting_path }
      end
    end
  end

  def delete_photo_group
    Group.transaction do
      begin
        set_company.remove_photo_group!
        set_company.save
        flash[:success] = "Delete photo group successfully."
      rescue => e
        flash[:error] = e.message
      end

      respond_to do |format|
        format.html { redirect_to my_profile_path }
      end

    end
  end

  def update_profile

    respond_to do |format|
      cover_preset = update_profile_params[:cover_preset]
      avatar = update_profile_params[:avatar]
      cover = update_profile_params[:cover]
      description = update_profile_params[:description]
      fullname = update_profile_params[:fullname]
      first_signup = update_profile_params[:first_signup]
      fb_id = update_profile_params[:fb_id]

      if update_profile_params[:gender] || update_profile_params[:birthday]
        @current_member.update_personal = true
      end

      if update_profile_params[:show_recommend]
        @current_member.show_recommend = true
      else
        @current_member.show_recommend = false
      end
      
      init_avatar = ImageUrl.new(avatar)
      init_cover = ImageUrl.new(cover)

      CoverPreset.count_number_preset(cover_preset) if cover_preset

      @current_member.cover_preset = "0" if cover

      if cover && init_cover.from_image_url? # upload via url
        @current_member.remove_old_cover 
        @current_member.update_column(:cover, init_cover.split_cloudinary_url)
      end

      if avatar && init_avatar.from_image_url? # upload via url
        @current_member.remove_old_avatar
        @current_member.update_column(:avatar, init_avatar.split_cloudinary_url)
      end

      if fb_id
        unless fb_id.present?
          @current_member.sync_facebook = false
          @current_member.list_fb_id = []
        end
      end

      if @current_member.update(update_profile_params.except(:member_id))
        if fullname
          Activity.create_activity_my_self(@current_member, ACTION[:change_name])
        end

        if cover || cover_preset
          Activity.create_activity_my_self(@current_member, ACTION[:change_cover])
        end

        if avatar
          Activity.create_activity_my_self(@current_member, ACTION[:change_avatar])
        end

        if fullname || description || avatar
          FlushCached::Member.new(@current_member).clear_list_friends_all_members
        end

        if cover_preset.present? && @current_member.cover.present?
          @current_member.remove_old_cover
        end

        check_invited if first_signup.to_s.present?

        @member = @current_member.reload

        flash[:success] = "Update profile successfully."
        format.html { redirect_to account_setting_path }
        format.json
      else
        # puts "have error"
        @error_message = @current_member.errors.messages

        format.json
        format.html { render 'profile' ,errors: @error_message }
      end
    end
  end

  # def update_profile
  #   respond_to do |wants|
  #     wants.json { render json: {}, status: 503 }
  #   end
  # end

  def check_invited
    @list_invite = Invite.where(email: @current_member.email)
    @list_invite.update_all(invitee_id: @current_member.id)

    @list_invite.map(&:member_id).uniq.each do |friend_id|
      Friend.add_friend({ member_id: @current_member.id, friend_id: friend_id })
    end
  end

  def setting_default
    respond_to do |format|
      if @current_member.update!(setting: params[:setting])
        format.json { render json: Hash["response_status" => "OK"] }
      else
        format.json { render json: Hash["response_status" => "ERROR"]}
      end
    end
  end

  def all_request
    init_list_friend = Member::ListFriend.new(@current_member)

    @your_request = init_list_friend.your_request
    @friend_request = init_list_friend.friend_request

    init_list_group = Member::ListGroup.new(@current_member)

    @group_inactive = init_list_group.inactive

    @hash_member_count = init_list_group.hash_member_count

    @ask_join_group = @current_member.cached_ask_join_groups

    @is_your_request = Friend.check_add_friend?(@current_member, @your_request, init_list_friend.check_is_friend) if @your_request.present?

    @is_friend_request = Friend.check_add_friend?(@current_member, @friend_request, init_list_friend.check_is_friend) if @friend_request.present?

    clear_request_count if params[:clear_request]
  end

  def clear_request_count
    @current_member.update_columns(request_count: 0)  
  end

  def is_friend(member_obj, list_compare)
    Friend.add_friend?(member_obj, list_compare)
  end

  def activity
    @activity = Activity.find_by(member_id: @current_member.id)
    @activity_items = @activity.present? ? @activity.items.collect{|e| e if e["activity_at"] > 14.days.ago.to_i }.compact : []
  end

  def notify
    @notify = @current_member.received_notifies.without_deleted.less_than_3_days.order('created_at DESC').paginate(page: params[:next_cursor])
    @total_entries =  @notify.total_entries
    @next_cursor = @notify.next_page.nil? ? 0 : @notify.next_page
    clear_notification_count if params[:clear_notification]
  end

  def clear_notification_count
    @current_member.update_columns(notification_count: 0)
  end

  # def stats
  #   @stats_all = @current_member.get_stats_all
  # end

  def report
    begin
      @find_friend = Member.find_by(id: report_params[:id])
      @current_member.sent_reports.create!(reportee_id: @find_friend.id, message: report_params[:message])
      @find_friend.increment!(:report_count)

      if report_params[:block]
        Friend.block_or_unblock_friend({ member_id: report_params[:member_id], friend_id: @find_friend.id }, true)
      end
      render status: :created
    rescue => e
      @error_message = e.message
      redner status: :unprocessable_entity
    end
  end

  def index
  end

  def my_profile
    @waiting_info = WaitingList.new(@current_member).get_info
  end

  def check_valid_email
    @member_email = Member.where(email: params[:email]).present?
    respond_to do |wants|
      wants.json { render json: !@member_email }
    end
  end

  def check_valid_username
    @member_username = Member.where(username: params[:username]).present?
    respond_to do |wants|
      wants.json { render json: !@member_username }
    end
  end

  def activate_account
    if session[:activate_id] && session[:activate_email]
      render layout: "activate"
    else
      redirect_to users_signin_url
    end
  end

  def activate
    @invite_code = InviteCode.check_valid_invite_code(activate_params[:code])
  
    if @invite_code[:status]
      company = @invite_code[:object].company
      list_member_in_company = Company::ListMember.new(company).get_list_members.map(&:id)
      raise ExceptionHandler::UnprocessableEntity, "You're in #{company.name} Company." if list_member_in_company.include?(@current_member.id)
    end

    respond_to do |format|
      if activate_params[:code] == "CODEAPP"
        @current_member.update(bypass_invite: true)
        @activate = true
        @invite_code[:message] = "Success"
        # session[:member_id] = @current_member.id
        # cookies[:auth_token] = { value: member.auth_token, expires: 6.hour.from_now }
        @member = Member.find(params[:member_id])
        format.js
        format.json
        format.html { redirect_to dashboard_path }
      elsif @invite_code[:status]
        @group = Group.find_by(id: @invite_code[:object].group_id)
        begin
          if add_to_group_at_invite
            @activate = @current_member.member_invite_codes.create!(invite_code_id: @invite_code[:object].id)
            @activate.save
            @invite_code[:object].update!(used: true)
            @invite_code[:message] = "You joined #{@group.name} Group"

            @member = Member.find(params[:member_id])
          
            format.js
            format.json
            format.html { redirect_to dashboard_path }
          else
            @error_message = flash[:warning] = "You've already in #{@group.name} Group"
            format.json
            format.html { redirect_to users_activate_path }
          end
        end
      else
        flash[:warning] = @invite_code[:message]
        format.json
        format.html { redirect_to users_activate_path }
      end
    end
  end

  def send_request_code
    @new_request = false
    begin
      @request = @current_member.request_codes.first_or_create do |request|
        request.member_id = @current_member.id
        request.custom_properties = {}
        request.save
        @new_request = true
      end
    rescue => e
      
    end
  end

  def add_to_group_at_invite
    if @group
      init_list_group = Member::ListGroup.new(@current_member)

      find_my_group = init_list_group.active.map(&:id)
      unless find_my_group.include?(@group.id)
        @group.group_members.create!(member_id: @current_member.id, is_master: false, active: true)

        CompanyMember.add_member_to_company(@current_member, @find_company)

        Company::TrackActivityFeedGroup.new(@current_member, @group, "join").tracking
        @group.increment!(:member_count)
        FlushCached::Member.new(@current_member).clear_list_groups
        FlushCached::Group.new(@group).clear_list_members
        true
      else
        nil
      end
    end
  end

  def list_block
    @list_block = @current_member.cached_block_friend
  end

  def clear
    current_member.history_votes.delete_all
    flash[:success] = "Clear successfully."
    redirect_to root_url
  end

  private

  def find_group
    @find_group = Group.joins(:group_company).where("group_companies.company_id = #{@find_company.id}").first
  end

  def set_company
    @find_company = current_member.get_company
  end

  def report_params
    params.permit(:id, :member_id, :friend_id, :message, :block)
  end

  def update_profile_params
    params.permit(:show_recommend, :public_id, :fb_id, :cover_preset, :member_id, :username, :fullname, :avatar, :gender, :birthday, :sentai_name, :cover, :description, :sync_facebook, :anonymous, :anonymous_public, :anonymous_friend_following, :anonymous_group, :first_signup, :first_setting_anonymous, :receive_notify, list_fb_id: [])
  end

  def verify_email_params
    params.permit(:email)
  end

  def activate_params
    params.permit(:code, :member_id)
  end

  def group_params
    params.permit(:name, :description, :photo_group)
  end

  
end
