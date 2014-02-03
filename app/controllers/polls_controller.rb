class PollsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_current_member, only: [:create_poll, :qrcode, :public_poll, :group_poll, :vote_poll, :view_poll]
  before_action :signed_user, only: [:index, :series, :new]
  before_action :history_voted_viewed, only: [:public_poll, :group_poll]
  before_action :set_poll, only: [:show, :destroy]
  before_action :compress_gzip, only: [:public_poll]

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
    params[:poll][:public] = true if current_member.celebrity?
    @poll = Poll.new(polls_params)

    if @poll.save
      current_member.poll_members.create!(poll_id: @poll.id)
      puts "success"
      flash[:success] = "Create poll successfully."
      redirect_to root_url
    else
      puts "#{@poll.errors.full_messages}"
    end
  end

  def series
    @series = @current_member.poll_series.paginate(page: params[:page])
  end

  def show
    puts params[:id]
  end

  def qrcode
    @poll = Poll.find_by(id: params[:poll_id])
  end

  def public_poll
    @poll = Poll.get_public_poll(@current_member, { next_poll: params[:next_poll], type: params[:type]})
    puts "version => #{derived_version}"
    if derived_version >= 2
      friend_list = @current_member.poll_of_friends.map(&:followed_id) << @current_member.id
      if params[:type] == "active"
      @poll = Poll.active_poll.joins(:poll_members).includes(:poll_series, :member, :choices)
                  .where("poll_members.member_id = ? OR poll_members.member_id IN (?) OR public = ?", @current_member.id, friend_list, true)
      elsif params[:type] == "inactive"
      @poll = Poll.inactive_poll.joins(:poll_members).includes(:poll_series, :member, :choices)
                  .where("poll_members.member_id = ? OR poll_members.member_id IN (?) OR public = ?", @current_member.id, friend_list, true)
      else
      @poll = Poll.joins(:poll_members).includes(:poll_series, :member, :choices)
                  .where("poll_members.member_id = ? OR poll_members.member_id IN (?) OR public = ?", @current_member.id, friend_list, true)
      end
    end
  end

  def group_poll
    @poll = Poll.get_group_poll(@current_member, {next_poll: params[:next_poll]})
  end

  def create_poll
    @poll = Poll.create_poll(poll_params, @current_member)
  end

  def vote_poll
    @poll, @history_voted = Poll.vote_poll(vote_params)
    @vote = Hash["voted" => true, "choice_id" => @history_voted.choice_id] if @history_voted
  end

  def view_poll
    @poll = Poll.view_poll(vote_params)
  end

  def destroy
    @poll.destroy
    flash[:notice] = "Destroy successfully."
    redirect_to root_url
  end

  private

  def set_poll
    @poll = Poll.find(params[:id])
  end

  def vote_params
    params.permit(:poll_id, :choice_id, :member_id)
  end

  def poll_params
    params.permit(:title, :expire_date, :member_id, :friend_id, :choices, :group_id, :api_version)
  end

  def polls_params
    params.require(:poll).permit(:member_id, :title, :expire_date, :public, choices_attributes: [:id, :answer, :_destroy])
  end
end
