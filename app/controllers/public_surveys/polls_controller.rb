class PublicSurveys::PollsController < ApplicationController

  before_action :only_public_survey
  before_action :set_poll, only: [:show, :edit, :update, :destroy]

  expose(:poll) { @poll.decorate }
  expose(:member) { @poll.member.decorate }

  def index
    @init_poll_public = Company::PollPublic.new(current_company)
    @public_polls = @init_poll_public.get_list_public_poll.decorate
  end

  def new
    @poll = Poll.new
  end

  def show
    @member = @poll.member
    @poll = @poll.decorate
    @choice_data_chart = []
    @poll_data = []

    @choice_poll = @poll.cached_choices.collect{|e| [e.answer, e.vote] }
    @choice_poll_latest_max = @choice_poll.collect{|e| e.last }.max

    @choice_poll.each do |choice|
      @poll_data << { "name" => choice.first, "value" => choice.last }
    end

    if current_member.get_company.present?
      init_company = PollDetailCompany.new(@poll.groups, @poll)
      @member_group = init_company.get_member_in_group
      @member_voted_poll = init_company.get_member_voted_poll
      @member_novoted_poll = init_company.get_member_not_voted_poll
      @member_viewed_poll = init_company.get_member_viewed_poll
      @member_noviewed_poll = init_company.get_member_not_viewed_poll
      @member_viewed_no_vote_poll = init_company.get_member_viewed_not_vote_poll

      @qr = RQRCode::QRCode.new(GenerateQrcodeLink.new(@poll).get_redirect_link, :size => 8, :level => :h ).to_img.resize(200, 200).to_data_url

      if @member_group.size > 0
        @percent_vote = ((@member_voted_poll.size * 100)/@member_group.size).to_s
        @percent_novote = ((@member_novoted_poll.size * 100)/@member_group.size).to_s
        @percent_view = ((@member_viewed_poll.size * 100)/@member_group.size).to_s
        @percent_noview = ((@member_noviewed_poll.size * 100)/@member_group.size).to_s
      else
        zero_percent = "0"
        @percent_vote = zero_percent
        @percent_novote = zero_percent
        @percent_view = zero_percent
        @percent_noview = zero_percent
      end
    end
  end

  def edit
    @groups = Group.eager_load(:group_company, :poll_groups, :group_members).where("group_companies.company_id = #{current_company.id}").uniq
  end

  def update
    if update_poll_params[:expire_status].to_b
      @poll.expire_date = Time.zone.now
    end

    if update_poll_params[:remove_campaign].to_b
      @poll.campaign_id = 0
    end

    if @poll.update(update_poll_params)
      flash[:success] = "Successfully updated..."
      redirect_to public_survey_poll_path(@poll)
    else
      flash[:error] = "Something weng wrong"
      redirect_to edit_public_survey_poll_path(@poll)
    end
  end

  def destroy
    @poll.groups.each do |group|
      NotifyLog.poll_with_group_deleted(@poll, group)
    end

    if @poll.in_group
      @poll.poll_groups.update_all(deleted_by_id: current_member.id)
      Company::TrackActivityFeedPoll.new(current_member, @poll.in_group_ids, @poll, 'delete').tracking
    end

    NotifyLog.check_update_poll_deleted(@poll)
    @poll.destroy
    @poll.member.flush_cache_about_poll
    DeletePoll.create_log(@poll)
    flash[:success] = "Destroy successfully."
    redirect_to public_survey_polls_path
  end

  private

  def set_poll
    @poll = Poll.cached_find(params[:id])
    if @poll.in_group
      raise ExceptionHandler::Forbidden if (@poll.groups.map(&:id) & Company::ListGroup.new(current_company).all.map(&:id)).size < 0
    else
      raise ExceptionHandler::Forbidden if (@poll.member.id != current_member.id) || !@poll.public
    end
  end

  def update_poll_params
    params.require(:poll).permit(:expire_status, :campaign_id, :draft, :close_status, :remove_campaign)
  end

end
