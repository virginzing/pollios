class PollsController < ApplicationController

  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?

  before_action :set_current_member, only: [:set_expire, :poke_dont_view, :poke_view_no_vote, :poke_dont_vote, :delete_comment, :comment, :choices, :delete_poll, :report, :watch, :unwatch, :detail, :hashtag_popular, :hashtag, 
                :scan_qrcode, :hide, :create_poll, :public_poll, :friend_following_poll, :reward_poll_timeline, :overall_timeline, :group_timeline, :vote_poll, :view_poll, :tags, :my_poll, :share, :my_watched, :my_vote, :unshare, :vote]
  before_action :set_current_guest, only: [:guest_poll]
  
  before_action :signed_user, only: [:show, :poll_latest, :poll_popular, :binary, :freeform, :rating, :index, :series, :new]
  
  before_action :history_voted_viewed_guest, only: [:guest_poll]
  
  before_action :set_poll, only: [:set_expire, :poke_dont_view, :poke_view_no_vote, :poke_dont_vote, :delete_comment, :load_comment, :comment, :delete_poll, :report, :watch, :unwatch, :show, :destroy, :vote, :view, :choices, :share, :unshare, :hide, :new_generate_qrcode, :scan_qrcode, :detail]
  
  before_action :compress_gzip, only: [:load_comment, :detail, :reward_poll_timeline, :hashtag_popular, :hashtag, :public_poll, :my_poll, :my_vote, 
                :my_watched, :friend_following_poll, :group_timeline, :overall_timeline, :reward_poll_timeline]

  before_action :get_your_group, only: [:detail, :create_poll]
  
  # before_action :restrict_access, only: [:overall_timeline]
  after_action :set_last_update_poll, only: [:public_poll, :overall_timeline]

  before_action :load_resource_poll_feed, only: [:overall_timeline, :public_poll, :friend_following_poll, :group_timeline, :reward_poll_timeline,
                :detail, :hashtag, :scan_qrcode, :tags, :my_poll, :my_vote, :my_watched, :hashtag_popular]

  expose(:list_recurring) { current_member.get_recurring_available }
  expose(:share_poll_ids) { @current_member.cached_shared_poll.map(&:poll_id) }
  expose(:watched_poll_ids) { @current_member.cached_watched.map(&:poll_id) }

  respond_to :json

  def poll_latest
    @poll_latest = Poll.where(member_id: @current_member.id, series: false).first
    @choice_poll_latest = []
    render layout: false
  end

  def poll_popular
    @poll_popular = Poll.where("member_id = #{@current_member.id} AND vote_all != 0 AND series = 'f'").order("vote_all desc").limit(5).sample(5).first
    @choice_poll_popular = []
    render layout: false
  end

  def generate_qrcode
    @qr = QrcodeSerializer.new(Poll.find(params[:id])).as_json.to_json
    puts "#{@qr}"
    respond_to do |format|
      format.json
      format.html
      format.svg  { render :qrcode => @qr, :level => :h, :size => 4 }
      format.png  { render :qrcode => @qr, :level => :h, :unit => 4, layout: false }
      format.gif  { render :qrcode => @qr }
      format.jpeg { render :qrcode => @qr }
    end
  end

  def set_last_update_poll
    @current_member.update_columns(poll_public_req_at: Time.now) if action_name == "public_poll"
    @current_member.update_columns(poll_overall_req_at: Time.now) if action_name == "overall_timeline"
  end

  def new_generate_qrcode
    puts params[:id]
    @poll.update!(qrcode_key: SecureRandom.hex(5))
    flash[:success] = "Re-Generate QRCode"
    respond_to do |wants|
       wants.html { redirect_to polls_path }
     end
  end

  def scan_qrcode
    from_scan = Qrcode.new(scan_qrcode_params)
    @poll = from_scan.poll_detail
    puts "@poll => #{@poll.as_json()}"
  end

  def new
    @poll = Poll.new
  end

  def binary
    @poll = Poll.new
  end

  def rating
    @poll = Poll.new
  end

  def freeform
    @poll = Poll.new
  end

  def index
    @polls = Poll.where(member_id: current_member.id, series: false).paginate(page: params[:page])
  end

  def create ## for Web
    Poll.transaction do
      in_group = false
      @build_poll = BuildPoll.new(current_member, polls_params, {choices: params[:choices]})
      new_poll_binary_params = @build_poll.poll_binary_params
      # puts "new_poll_binary_params => #{new_poll_binary_params}"
      @poll = Poll.new(new_poll_binary_params)
      @poll.choice_count = @build_poll.list_of_choice.count
      
      if @poll.save

        @choice = Choice.create_choices_on_web(@poll.id, @build_poll.list_of_choice)

        @poll.create_tag(@build_poll.title_with_tag)

        @poll.create_watched(current_member, @poll.id)

        if @poll.in_group_ids != "0"
          in_group = true
          puts "#{ @poll.in_group_ids}"
          Group.add_poll(current_member, @poll, @poll.in_group_ids)
        else
          ApnPollWorker.perform_async(current_member.id, @poll.id) if Rails.env.production?
        end

        unless @poll.qr_only
          current_member.poll_members.create!(poll_id: @poll.id, share_poll_of_id: 0, public: @poll.public, series: @poll.series, expire_date: @poll.expire_date, in_group: in_group)
        end
        
        PollStats.create_poll_stats(@poll)
        # Rails.cache.delete([current_member.id, 'poll_member'])
        Rails.cache.delete([current_member.id, 'my_poll'])
        Activity.create_activity_poll(current_member, @poll, 'Create')

        flash[:success] = "Create poll successfully."
        redirect_to polls_path
      else
        # puts "#{@poll.errors.full_messages}"
        render @build_poll.type_poll
      end
    end
  end

  def delete_poll
    Poll.transaction do
      begin
        if @poll.member_id == @current_member.id
          @poll.destroy
          if @poll.in_group_ids != 0
            Group.where("id IN (?)", @poll.in_group_ids.split(",")).collect {|group| group.decrement!(:poll_count)}
          end
          Rails.cache.delete([current_member.id, 'my_poll'])
        end
      rescue => e
        @error_message = e.message
      end
    end
  end

  # def series
  #   @series = @current_member.poll_series.paginate(page: params[:page])
  # end

  def list_history_vote_poll
    @list_history_vote_poll = Member.joins("left outer join history_votes on members.id = history_votes.member_id")
                  .select("members.*, history_votes.created_at as voted_at")
                  .where("history_votes.poll_id = ? AND members.id IN (?)", @poll.id, @member_group_ids)

    @member_voted_poll = @list_history_vote_poll.select {|e| e if e.voted_at.present? }
    @member_novoted_poll = Member.where("id IN (?)", @member_group_ids - @member_voted_poll.map(&:id))
  end

  def list_history_view_poll
    @list_history_view_poll = Member.joins("left outer join history_views on members.id = history_views.member_id")
                  .select("members.*, history_views.created_at as viewed_at")
                  .where("history_views.poll_id = ? AND members.id IN (?)", @poll.id, @member_group_ids)

    @member_viewed_poll = @list_history_view_poll.select {|e| e if e.viewed_at.present? }
    @member_noviewed_poll = Member.where("id IN (?)", @member_group_ids - @member_viewed_poll.map(&:id))
  end

  def show
    @choice_data_chart = []
    if current_member.company?
      load_resoure_group

      list_history_vote_poll

      list_history_view_poll

      @member_view_but_no_vote = @member_viewed_poll.map(&:id)

      member_voted_poll_ids ||= @member_voted_poll.map(&:id)

      @member_viewed_no_vote_poll = @member_viewed_poll.select {|e| e unless member_voted_poll_ids.include?(e.id) }

      if @member_group.count > 0
        @percent_vote = ((@member_voted_poll.count * 100)/@member_group.count).to_s
        @percent_novote = ((@member_novoted_poll.count * 100)/@member_group.count).to_s

        @percent_view = ((@member_viewed_poll.count * 100)/@member_group.count).to_s
        @percent_noview = ((@member_noviewed_poll.count * 100)/@member_group.count).to_s
      else
        zero_percent = "0"
        @percent_vote = zero_percent
        @percent_novote = zero_percent
        @percent_view = zero_percent
        @percent_noview = zero_percent
      end
    end

  end

  def poke_dont_vote
    respond_to do |format|
      load_resoure_group
      list_history_vote_poll

      if @member_novoted_poll.length > 0
        ApnPokePollWorker.perform_async(@current_member.id, @member_novoted_poll.collect{|e| e.id }, @poll.id)

        format.json { render json: [], status: 200 }
      else
        format.json { render json: { error_message: "No" }, status: 403 }
      end
    end
  end

  def poke_dont_view
    respond_to do |format|
      load_resoure_group
      list_history_view_poll

      if @member_noviewed_poll.length > 0
        ApnPokePollWorker.perform_async(@current_member.id, @member_noviewed_poll.collect{|e| e.id }, @poll.id)

        format.json { render json: [], status: 200 }
      else
        format.json { render json: { error_message: "No" }, status: 403 }
      end
    end
  end

  def poke_view_no_vote
    respond_to do |format|
      load_resoure_group
      list_history_vote_poll
      list_history_view_poll

      member_voted_poll_ids ||= @member_voted_poll.map(&:id)
      @member_viewed_no_vote_poll = @member_viewed_poll.select {|e| e unless member_voted_poll_ids.include?(e.id) }

      if @member_viewed_no_vote_poll.length > 0
        ApnPokePollWorker.perform_async(@current_member.id, @member_viewed_no_vote_poll.collect{|e| e.id }, @poll)

        format.json { render json: [], status: 200 }
      else
        format.json { render json: { error_message: "No" }, status: 403 }
      end
    end
  end

  def set_expire
    respond_to do |format|
      if (@poll.member_id == @current_member.id) && @poll.update_attributes!(expire_status: true)
        format.json { render json: Hash["response_status" => "OK", "response_message" => "Success" ] }
      else
        format.json { render json: Hash["response_status" => "ERROR", "response_message" => @poll.errors.full_messages.presence || "ERROR" ] }
      end
    end
  end

  def qrcode
    @poll = Poll.find_by(id: params[:poll_id])
  end

  def choices
    @expired = @poll.expire_date < Time.now
    @choices = @poll.cached_choices
    @voted = HistoryVote.voted?(@current_member, @poll.id)
  end

  def public_poll
    if derived_version == 4
      @poll_series, @series_shared, @poll_nonseries, @nonseries_shared, @next_cursor = Poll.list_of_poll(@current_member, ENV["PUBLIC_POLL"], options_params)
    elsif derived_version == 5
      @init_poll = PublicTimelinable.new(public_poll_params, @current_member)

      @poll_paginate = @init_poll.poll_public.paginate(page: params[:next_cursor])

      @polls = public_poll_params["pull_request"] == "yes" ? @poll_paginate.per_page(1000) : @poll_paginate

      @poll_series, @poll_nonseries = Poll.split_poll(@polls)
      @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
      @total_entries = @polls.total_entries
    else
      @init_poll = PublicTimelinable.new(public_poll_params, @current_member)

      @poll_paginate = @init_poll.poll_public.paginate(page: params[:next_cursor])

      @polls = public_poll_params["pull_request"] == "yes" ? @poll_paginate.per_page(1000) : @poll_paginate

      @poll_series, @poll_nonseries = Poll.split_poll(@polls)
      @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
      @total_entries = @polls.total_entries
    end
  end

  def detail
    Poll.view_poll({ id: @poll.id, member_id: @current_member.id})
    @expired = @poll.expire_date < Time.now
    @voted = @current_member.list_voted?(@poll)
  end

  def friend_following_poll
    friend_following_timeline = FriendFollowingTimeline.new(@current_member, options_params)
    @poll_series, @series_shared, @poll_nonseries, @nonseries_shared, @next_cursor = friend_following_timeline.poll_friend_following
    @group_by_name = friend_following_timeline.group_by_name
    @total_entries = friend_following_timeline.total_entries
  end

  def overall_timeline
    overall_timeline = OverallTimeline.new(@current_member, options_params)
    @poll_series, @series_shared, @poll_nonseries, @nonseries_shared, @next_cursor = overall_timeline.poll_overall
    @group_by_name = overall_timeline.group_by_name
    @total_entries = overall_timeline.total_entries
    @unvote_count = overall_timeline.unvote_count
  end

  # def group_timeline
  #   @init_poll = GroupTimelinable.new(@current_member, public_poll_params)
  #   @polls = @init_poll.group_poll.paginate(page: params[:next_cursor])
  #   poll_helper
  # end
  def group_timeline
    group_timeline = GroupTimelinable.new(@current_member, options_params)
    @poll_series, @series_shared, @poll_nonseries, @nonseries_shared, @next_cursor = group_timeline.group_polls
    @group_by_name = group_timeline.group_by_name
    @total_entries = group_timeline.total_entries
  end

  def reward_poll_timeline
    @init_poll = PollRewardTimeline.new(@current_member, public_poll_params)
    @polls = @init_poll.reward_poll.paginate(page: params[:next_cursor])
    poll_helper
  end

  def my_poll
    @init_poll = MyPollInProfile.new(@current_member, options_params)
    @polls = @init_poll.my_poll.paginate(page: params[:next_cursor])
    poll_helper
  end

  def my_vote
    @init_poll = MyPollInProfile.new(@current_member, options_params)
    @polls = @init_poll.my_vote.paginate(page: params[:next_cursor])
    poll_helper
  end

  def my_watched
    @init_poll = MyPollInProfile.new(@current_member, options_params)
    @polls = @init_poll.my_watched.paginate(page: params[:next_cursor])
    poll_helper
  end

  def poll_helper
    @poll_series, @poll_nonseries = Poll.split_poll(@polls)
    @group_by_name ||= @init_poll.group_by_name
    @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
    @total_entries = @polls.total_entries
  end


  def guest_poll
    if params[:type] == "active"
      query_poll = Poll.active_poll
    elsif params[:type] == "inactive"
      query_poll = Poll.inactive_poll
    else
      query_poll = Poll.all
    end

    if params[:next_cursor]
      @poll = query_poll.includes(:poll_series, :member).where("id < ? AND public = ?)", params[:next_cursor], true).order("created_at desc")
    else
      @poll = query_poll.includes(:poll_series, :member).where("public = ?", true).order("created_at desc")
    end

    @poll_series, @poll_nonseries, @next_cursor = Poll.split_poll(@poll)
  end


  def tags
    @find_tag = Tag.find_by(name: params[:name])
    friend_list = @current_member.get_friend_active.map(&:id) << @current_member.id

    if params[:type] == "series"
      query_poll = @find_tag.poll_series
    else
      query_poll = @find_tag.polls.where(series: false)
    end
    puts "query_poll => #{query_poll}"
    if params[:next_cursor]
      @poll = query_poll.joins(:poll_members).includes(:poll_series, :member)
                          .where("poll_members.poll_id < ? AND (poll_members.member_id IN (?) OR public = ?)", params[:next_cursor], friend_list, true)
                          .order("poll_members.created_at desc")
    else
      @poll = query_poll.joins(:poll_members).includes(:poll_series, :member)
                          .where("poll_members.member_id IN (?) OR public = ?", friend_list, true)
                          .order("poll_members.created_at desc")
    end
  end


  def hashtag
    hashtag = HashtagTimeline.new(@current_member, hashtag_params)
    @polls = hashtag.get_hashtag.paginate(page: params[:next_cursor])
    @poll_series, @poll_nonseries = Poll.split_poll(@polls)
    @group_by_name = hashtag.group_by_name
    @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
    @total_entries = @polls.total_entries
  end

  def hashtag_popular
    hashtag = HashtagTimeline.new(@current_member, hashtag_params)
    @tag_lists = hashtag.get_hashtag_popular
  end

  def vote
    @poll, @history_voted = Poll.vote_poll(view_and_vote_params, @current_member)
    @vote = Hash["voted" => true, "choice_id" => @history_voted.choice_id] if @history_voted
  end

  def view
    @poll = Poll.view_poll(view_and_vote_params)
  end

  def create_poll
    @poll, @error_message = Poll.create_poll(poll_params, @current_member)
  end

  def share
    @init_share = SharedPoll.new(@current_member, @poll, options_params)
    @shared = @init_share.share
    @init_share.save_activity
  end

  def unshare
    @init_share = SharedPoll.new(@current_member, @poll, options_params)
    @unshare = @init_share.unshare
  end

  def watch
    @init_watch = WatchPoll.new(@current_member, params[:id])
    @watch = @init_watch.watching
  end

  def unwatch
    @init_watch = WatchPoll.new(@current_member, params[:id])
    @watch = @init_watch.unwatch
  end

  def hide
    @hide = @current_member.hidden_polls.create!(poll_id: params[:id])
  end

  def report
    @init_report = ReportPoll.new(@current_member, @poll, { message: params[:message]} )
    @report = @init_report.reporting
  end

  def destroy
    @poll.destroy
    flash[:notice] = "Destroy successfully."
    redirect_to polls_url
  end

  # Comment

  def comment  #post comment
    Poll.transaction do
      begin
        @comment = Comment.create!(poll_id: @poll.id, member_id: @current_member.id, message: comment_params[:message])
        @poll.increment!(:comment_count)
        # puts "#{@current_member.id == @poll.member_id}"
        find_watched = Watched.where(member_id: @current_member.id, poll_id: @poll.id)

        if find_watched.first.present?
          find_watched.first.update(comment_notify: true) if find_watched.where(comment_notify: false)
        else
          Watched.create!(member_id: @current_member.id, poll_id: @poll.id, poll_notify: false, comment_notify: true)
        end
        Activity.create_activity_comment(@current_member, @poll, 'Comment')
        CommentPollWorker.perform_async(@current_member.id, @poll.id, { comment_message: @comment.message })
      rescue => e
        @error_message = e.message
        puts "#{e.message}"
      end
    end
  end

  def load_comment
    @comments = Comment.joins(:member).select("comments.*, members.fullname as member_fullname, members.avatar as member_avatar").where(poll_id: comment_params[:id], delete_status: false).order("created_at desc").paginate(page: comment_params[:next_cursor])
    @new_comment_sort ||= @comments.sort! { |x,y| x.created_at <=> y.created_at }
    @comments_as_json = ActiveModel::ArraySerializer.new(@new_comment_sort, each_serializer: CommentSerializer).as_json()
    @next_cursor = @comments.next_page.nil? ? 0 : @comments.next_page
    @total_entries = @comments.total_entries
  end

  def delete_comment
    Poll.transaction do
      begin
        @comment = Comment.find_by(id: comment_params[:comment_id]) || 0
        if @comment.member_id == @current_member.id
          @comment.update(delete_status: true)
          @poll.decrement!(:comment_count) if @poll.comment_count > 0
        else
          @comment = nil
          @error_message = "Only creator's comment"
        end
      rescue => e
        @error_message = e.message
      end
    end
  end

  private

  def set_poll
    begin
      @poll = Poll.cached_find(params[:id])
    rescue => e
      respond_to do |wants|
        wants.json { render json: Hash["response_status" => "ERROR", "response_message" => e.message ] }
      end
    end
  end

  def comment_params
    params.permit(:id, :message, :next_cursor, :comment_id, :member_id)
  end

  def hashtag_params
    params.permit(:member_id, :name, :type, :next_cursor)
  end

  def public_poll_params
    params.permit(:member_id, :type, :since_id, :pull_request)
  end

  def scan_qrcode_params
    params.permit(:id, :member_id, :qrcode_key)
  end

  def options_params
    params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request, :group_id, :public, :friend_following, :group, :my_poll, :my_vote, :reward)
  end

  def options_build_params
    params.permit(:choices => [])
  end

  def choices_params
    params.permit(:id, :member_id, :voted)
  end

  def view_and_vote_params
    params.permit(:id, :member_id, :choice_id, :guest_id)
  end

  def vote_params
    params.permit(:poll_id, :choice_id, :member_id, :id, :guest)
  end

  def poll_params
    params.permit(:title, :expire_date, :member_id, :friend_id, :group_id, :api_version, :poll_series_id, :series, :choice_count, :recurring_id, :expire_within, :type_poll, :is_public, :photo_poll, :allow_comment, :buy_poll, :choices => [])
  end

  def polls_params
    params.require(:poll).permit(:qr_only, :require_info, :allow_comment, :member_type, :campaign_id, :member_id, :title, :public, :expire_within, :expire_date, :choice_count ,:tag_tokens, :recurring_id, :type_poll, :choice_one, :choice_two, :choice_three, :photo_poll, :title_with_tag, choices_attributes: [:id, :answer, :_destroy])
  end

  protected

  def json_request?
    request.format.json?
  end

  def load_resoure_group
    @group = current_member.present? ? current_member.company.group : @current_member.company.group 
    @member_group = @group.get_member_active
    @member_group_ids = @member_group.map(&:id)
  end

end
