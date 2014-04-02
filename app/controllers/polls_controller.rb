class PollsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_current_member, only: [:scan_qrcode, :hide, :create_poll, :public_poll, :friend_following_poll, :overall_timeline, :group_poll, :group_timeline, :vote_poll, :view_poll, :tags, :new_public_timeline, :my_poll, :share, :my_vote, :unshare]
  before_action :set_current_guest, only: [:guest_poll]
  before_action :signed_user, only: [:index, :series, :new]
  before_action :history_voted_viewed, only: [:scan_qrcode, :public_poll, :group_poll, :tags, :new_public_timeline, :my_poll, :my_vote, :friend_following_poll, :group_timeline, :overall_timeline]
  before_action :history_voted_viewed_guest, only: [:guest_poll]
  before_action :set_poll, only: [:show, :destroy, :vote, :view, :choices, :share, :unshare, :hide, :new_generate_qrcode, :scan_qrcode]
  before_action :compress_gzip, only: [:public_poll, :my_poll, :my_vote, :friend_following_poll, :group_timeline, :overall_timeline]
  # before_action :restrict_access, only: [:public_poll]

  expose(:list_recurring) { current_member.get_recurring_available }
  expose(:share_poll_ids) { @current_member.share_polls.pluck(:poll_id) }
  # :restrict_access

  respond_to :json

  def generate_qrcode

    qrurl = QrcodeSerializer.new(Poll.find(params[:id])).as_json.to_json

    # @qr = RQRCode::QRCode.new( @qrurl , :unit => 11, :level => :m , size: 30)
    base64_qrcode = Base64.strict_encode64(qrurl)
    @qrcode = URI.encode(base64_qrcode)

    puts "qrcode encode base64 => #{base64_qrcode}"
    puts "qrcode => #{qrurl}"

    respond_to do |format|
      format.json
      format.html
      format.svg  { render :qrcode => qrurl, :level => :h, :size => 10 }
      format.png  { render :qrcode => base64_qrcode, :level => :h, :unit => 4, :color => 'FF5A5A' , :offset => 10 }
      format.gif  { render :qrcode => qrurl, :level => :h, :unit => 4, :color => 'FF5A5A' , :offset => 10 }
      format.jpeg { render :qrcode => qrurl }
    end
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
    @tags = Tag.all
  end

  def index
    @polls = Poll.where(member_id: current_member.id, series: false).paginate(page: params[:page])
  end

  def create
    params[:poll][:member_id] = current_member.id
    params[:poll][:expire_date] = Time.now + params[:poll][:expire_date].to_i.days
    params[:poll][:public] = false
    params[:poll][:series] = false
    params[:poll][:public] = true if current_member.celebrity? || params[:poll][:recurring_id].present? || current_member.brand?

    choice_array = []
    choice_array << params[:poll][:choice_one]
    choice_array << params[:poll][:choice_two]
    choice_array = choice_array + params[:choices]

    filter_choice = choice_array.collect!{|value| value unless value.blank? }.compact
 
    params[:poll][:choice_count] = filter_choice.count
    group_id = params[:poll][:group_id]

    @poll = Poll.new(polls_params)
    @poll.poll_series_id = 0
    @poll.in_group_ids = group_id.present? ? group_id.join(",") : "0"

    if @poll.save
      Choice.create_choices(@poll.id, filter_choice)
      current_member.poll_members.create!(poll_id: @poll.id, share_poll_of_id: 0, public: @poll.public, series: @poll.series, expire_date: @poll.expire_date) unless group_id.presence
      if group_id.present?
        Group.add_poll(@poll.id, group_id.join(","))
        current_member.poll_members.create!(poll_id: @poll.id, share_poll_of_id: 0, public: @poll.public, series: @poll.series, expire_date: @poll.expire_date, in_group: true) 
      end

      Rails.cache.delete([current_member.id, 'poll_member'])
      Rails.cache.delete([current_member.id, 'poll_count'])

      puts "success"
      flash[:success] = "Create poll successfully."
      redirect_to polls_path
    else
      puts "#{@poll.errors.full_messages}"
    end
  end

  # def series
  #   @series = @current_member.poll_series.paginate(page: params[:page])
  # end

  def show
    puts params[:id]
  end

  def qrcode
    @poll = Poll.find_by(id: params[:poll_id])
  end

  def choices
    @expired = @poll.expire_date < Time.now
    puts "expired => #{@expired}"
    @choices = Choice.query_choices(choices_params, @expired)
    @voted = HistoryVote.voted?(choices_params[:member_id], @poll.id)
    # unless choices_params[:voted] == "no"
      # @voted = HistoryVote.voted?(choices_params[:member_id], @poll.id)["voted"]
    # end
  end

  def public_poll
    puts "version => #{derived_version}"
    if derived_version == 1
      @poll = Poll.get_public_poll(@current_member, { next_poll: params[:next_poll], type: params[:type]})
    elsif derived_version == 2
      friend_list = @current_member.whitish_friend.map(&:followed_id) << @current_member.id
      if params[:type] == "active"
        query_poll = Poll.active_poll.includes(:choices)
      elsif params[:type] == "inactive"
        query_poll = Poll.inactive_poll.includes(:choices)
      else
        query_poll = Poll.includes(:choices)
      end

      @poll = query_poll.joins(:poll_members).includes(:poll_series, :member)
                    .where("poll_members.member_id = ? OR poll_members.member_id IN (?) OR public = ?", @current_member.id, friend_list, true)

    elsif derived_version == 3
      friend_list = @current_member.whitish_friend.map(&:followed_id) << @current_member.id
      if params[:type] == "active"
        query_poll = Poll.active_poll
      elsif params[:type] == "inactive"
        query_poll = Poll.inactive_poll
      else
        query_poll = Poll.all
      end

      if params[:next_cursor]
        @poll = query_poll.joins(:poll_members).includes(:poll_series, :member)
                          .where("poll_members.poll_id < ? AND (poll_members.member_id IN (?) OR public = ?)", params[:next_cursor], friend_list, true)
                          .order("poll_members.created_at desc")
      else
        @poll = query_poll.joins(:poll_members).includes(:poll_series, :member).where("poll_members.member_id IN (?) OR public = ?", friend_list, true)
                          .order("poll_members.created_at desc")
      end

      @poll_series, @poll_nonseries, @next_cursor = Poll.split_poll(@poll)
      puts "series => #{@poll_series.map(&:id)}"
      puts "nonseries => #{@poll_nonseries.map(&:id)}"
    elsif derived_version == 4
      @poll_series, @series_shared, @poll_nonseries, @nonseries_shared, @next_cursor = Poll.list_of_poll(@current_member, ENV["PUBLIC_POLL"], options_params)
    elsif derived_version == 5
      @public_poll = PublicTimelinable.new(public_poll_params)
      @polls = @public_poll.poll_public.paginate(page: params[:next_cursor])
      @poll_series, @poll_nonseries = Poll.split_poll(@polls)
      @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
    end
  end

  def friend_following_poll
    @poll_series, @series_shared, @poll_nonseries, @nonseries_shared, @next_cursor = Poll.list_of_poll(@current_member, ENV["FRIEND_FOLLOWING_POLL"], options_params)
  end

  def overall_timeline
    @poll_series, @series_shared, @poll_nonseries, @nonseries_shared, @next_cursor = Poll.list_of_poll(@current_member, ENV["OVERALL_TIMELINE"], options_params)
    @group_by_name = OverallTimeline.new(@current_member, {}).group_by_name
  end

  def group_timeline
    @group_poll = GroupTimelinable.new(public_poll_params, @current_member)
    @polls = @group_poll.group_poll.joins(:poll_groups).paginate(page: params[:next_cursor])
    @poll_series, @poll_nonseries = Poll.split_poll(@polls)
    @group_by_name ||= @group_poll.group_by_name
    # puts "group_by_name = #{@group_by_name}"
    # puts "page = #{@polls.next_page}"
    @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
  end

  def my_poll
    @poll_nonseries, @next_cursor = Poll.get_my_vote_my_poll(@current_member, ENV["MY_POLL"], options_params)
  end

  def my_vote
    # @poll_nonseries, @next_cursor = Poll.get_my_vote_my_poll(@current_member, ENV["MY_VOTE"], options_params)
    @poll_nonseries = Poll.joins(:history_votes).includes(:member).where("history_votes.member_id = ? AND history_votes.poll_series_id = 0", @current_member.id).order("history_votes.created_at DESC").paginate(page: params[:next_cursor])
    @next_cursor = @poll_nonseries.next_page.nil? ? 0 : @poll_nonseries.next_page
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
    friend_list = @current_member.whitish_friend.map(&:followed_id) << @current_member.id

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

  def vote
    @poll, @history_voted = Poll.vote_poll(view_and_vote_params)
    @vote = Hash["voted" => true, "choice_id" => @history_voted.choice_id] if @history_voted
  end

  def view
    @poll = Poll.view_poll(view_and_vote_params)
  end

  def create_poll
    @poll = Poll.create_poll(poll_params, @current_member)
  end

  def share
    new_record = false
    @share = @poll.poll_members.where("member_id = ?", @current_member.id).first_or_create do |pm|
      pm.member_id = @current_member.id
      pm.poll_id = @poll.id
      pm.share_poll_of_id = @poll.id
      pm.public = @poll.public
      pm.series = @poll.series
      pm.expire_date = @poll.expire_date
      pm.save
      new_record = true
    end

    if new_record
      @poll.increment!(:share_count)
      @current_member.set_share_poll(@poll.id)
    end
  end

  def unshare
    find_poll = @poll.poll_members.find_by_member_id(@current_member.id)
    if find_poll.present?
      find_poll.destroy
      @current_member.share_polls.find_by_poll_id(@poll.id).destroy
      @poll.decrement!(:share_count)
    end
    @poll
  end

  def hide
    @hide = @current_member.hidden_polls.create!(poll_id: params[:id])
  end

  def destroy
    @poll.destroy
    flash[:notice] = "Destroy successfully."
    redirect_to root_url
  end

  private

  def set_poll
    begin
      @poll = Poll.find(params[:id])
    rescue => e
      respond_to do |wants|
        wants.json { render json: Hash["response_status" => "ERROR", "response_message" => e.message ] }
      end
    end
  end

  def public_poll_params
    params.permit(:member_id, :type)
  end

  def scan_qrcode_params
    params.permit(:id, :member_id, :qrcode_key)
  end

  def options_params
    params.permit(:next_cursor, :type)
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
    params.permit(:title, :expire_date, :member_id, :friend_id, :choices, :group_id, :api_version, :poll_series_id, :series, :choice_count, :recurring_id, :expire_within, :type_poll)
  end

  def polls_params
    params.require(:poll).permit(:campaign_id, :member_id, :title, :expire_date, :public, :expire_within,  :choice_count ,:tag_tokens, :recurring_id, :type_poll, choices_attributes: [:id, :answer, :_destroy])
  end
end
