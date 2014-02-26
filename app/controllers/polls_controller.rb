class PollsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_current_member, only: [:create_poll, :public_poll, :group_poll, :vote_poll, :view_poll, :tags, :new_public_timeline, :my_poll, :share, :my_vote]
  before_action :set_current_guest, only: [:guest_poll]
  before_action :signed_user, only: [:index, :series, :new]
  before_action :history_voted_viewed, only: [:public_poll, :group_poll, :tags, :new_public_timeline, :my_poll, :my_vote]
  before_action :history_voted_viewed_guest, only: [:guest_poll]
  before_action :set_poll, only: [:show, :destroy, :vote, :view, :choices, :share]
  before_action :compress_gzip, only: [:public_poll, :my_poll, :my_vote]

  # :restrict_access

  respond_to :json

  # def generate_qrcode
  #   @qrurl = PollSeries.find(10).as_json(
  #               only: [:id, :description],
  #               methods: [:creator],
  #               include: { polls: { only: [:id, :title] } } 
  #             )
  #   respond_to do |format|
  #     format.html
  #     format.svg  { render :qrcode => @qrurl, :level => :h, :unit => 10 }
  #     format.png  { render :qrcode => @qrurl, :level => :h, :unit => 4 }
  #     format.gif  { render :qrcode => @qrurl }
  #     format.jpeg { render :qrcode => @qrurl }
  #   end
  # end


  def new
    @poll = Poll.new
  end

  def index
    @polls = Poll.where(member_id: current_member.id).paginate(page: params[:page])
  end

  def create
    params[:poll][:member_id] = current_member.id
    params[:poll][:expire_date] = Time.now + params[:poll][:expire_date].to_i.days
    params[:poll][:public] = false
    params[:poll][:series] = false
    params[:poll][:public] = true if current_member.celebrity?
    choice_array = []
    choice_array << params[:poll][:choice_one]
    choice_array << params[:poll][:choice_two]
    choice_array = choice_array + params[:choices]

    filter_choice = choice_array.collect!{|value| value unless value.blank? }.compact
 
    params[:poll][:choice_count] = filter_choice.count
    group_id = params[:poll][:group_id]
    @poll = Poll.new(polls_params)

    if @poll.save
      Choice.create_choices(@poll.id, filter_choice)
      current_member.poll_members.create!(poll_id: @poll.id, share_poll_of_id: 0, public: @poll.public, series: @poll.series, expire_date: @poll.expire_date) unless group_id.presence
      Group.add_poll(@poll.id, group_id) if group_id.present?
      puts "success"
      flash[:success] = "Create poll successfully."
      redirect_to root_url
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
    unless choices_params[:voted] == "no"
      @voted = HistoryVote.voted?(choices_params[:member_id], @poll.id)["voted"]
    end
  end

  def share
    
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
    else
      @poll_series, @series_shared, @poll_nonseries, @nonseries_shared, @next_cursor = Poll.list_of_poll(@current_member, ENV["PUBLIC_POLL"], options_params)
    end
  end

  # def my_poll
  #   @poll_series, @poll_nonseries, @next_cursor = Poll.list_of_poll(@current_member, ENV["MY_POLL"], options_params)
  # end

  # def my_vote
  #   @poll_series, @poll_nonseries, @next_cursor = Member.list_of_poll(@current_member, ENV["MY_VOTE"], options_params)
  # end

  def my_poll
    @poll_nonseries, @next_cursor = Poll.get_my_vote_my_poll(@current_member, ENV["MY_POLL"], options_params)
  end

  def my_vote
    @poll_nonseries, @next_cursor = Poll.get_my_vote_my_poll(@current_member, ENV["MY_VOTE"], options_params)
  end

  # def new_public_timeline
  #   @poll_series, @series_shared, @poll_nonseries, @nonseries_shared, @next_cursor = Poll.list_of_poll(@current_member, params[:next_cursor])
  # end

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

  def group_poll
    group_of_member = @current_member.groups.pluck(:id)
    if params[:type] == "active"
      query_poll = Poll.active_poll
    elsif params[:type] == "inactive"
      query_poll = Poll.inactive_poll
    else
      query_poll = Poll.all
    end

    if params[:next_cursor]
      @poll ||= query_poll.joins(:poll_groups).uniq
                          .includes(:poll_series, :member)
                          .where("poll_groups.poll_id < ? AND poll_groups.group_id IN (?)", params[:next_cursor], group_of_member)
    else
      @poll ||= query_poll.joins(:poll_groups).uniq
                          .includes(:poll_series, :member)
                          .where("poll_groups.group_id IN (?)", group_of_member)
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

  # def vote_poll
  #   @poll, @history_voted = Poll.vote_poll(vote_params)
  #   @vote = Hash["voted" => true, "choice_id" => @history_voted.choice_id] if @history_voted
  # end

  # def view_poll
  #   @poll = Poll.view_poll(vote_params)
  # end

  def destroy
    @poll.destroy
    flash[:notice] = "Destroy successfully."
    redirect_to root_url
  end

  private

  def set_poll
    @poll = Poll.find(params[:id])
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
    params.permit(:title, :expire_date, :member_id, :friend_id, :choices, :group_id, :api_version, :poll_series_id, :series, :choice_count)
  end

  def polls_params
    params.require(:poll).permit(:campaign_id, :member_id, :title, :expire_date, :public, :choice_count ,:tag_tokens, choices_attributes: [:id, :answer, :_destroy])
  end
end
