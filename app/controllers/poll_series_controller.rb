class PollSeriesController < ApplicationController
  include PollSeriesHelper
  skip_before_action :verify_authenticity_token
  before_action :signed_user, only: [:index, :new, :normal, :same_choice]
  before_action :set_current_member, only: [:vote, :detail]
  before_action :set_poll_series, only: [:edit, :update, :destroy, :vote, :generate_qrcode, :detail]
  before_action :load_resource_poll_feed, only: [:detail]
  def generate_qrcode
    # qrurl = PollSeries.includes(:polls).find(params[:id]).as_json().to_json
    # @qr = RQRCode::QRCode.new( @qrurl , :unit => 11, :level => :m , size: 30)
    qrurl = QrcodeSerializer.new(PollSeries.find(params[:id]).polls.last).as_json.to_json
    base64_qrcode = Base64.strict_encode64(qrurl)
    @qrcode = URI.encode(base64_qrcode)

    puts "qrcode json => #{base64_qrcode}"

    respond_to do |format|
      format.json
      format.html
      format.svg  { render :qrcode => qrurl, :level => :h, :size => 10 }
      format.png  { render :qrcode => @qrcode, :level => :h, :unit => 4 }
      format.gif  { render :qrcode => qrurl }
      format.jpeg { render :qrcode => qrurl }
    end
  end

  def detail
    # Poll.view_poll({ id: @poll.id, member_id: @current_member.id})
    # @expired = @poll.expire_date < Time.now
    # @voted = @current_member.list_voted?(@poll)
  end

  def vote
    puts "#{vote_params}"
    @votes = @poll_series.vote_questionnaire(vote_params, @current_member)
  end

  def index
    @poll_series = current_member.poll_series.paginate(page: params[:page])
    puts "#{@poll_series.to_a}"
  end

  def new
    @poll_series = PollSeries.new
    1.times do
      poll = @poll_series.polls.build
      2.times { poll.choices.build }
    end
  end

  def normal
    @poll_series = PollSeries.new
    1.times do
      poll = @poll_series.polls.build
      2.times do 
        poll.choices.build
      end
    end
  end

  def same_choice
    @poll_series = PollSeries.new
    2.times do
      @poll_series.polls.build
    end
  end

  def edit
    @poll_tags = @poll_series.tags
    puts "polltag = #{@poll_tags}"
  end

  def update
    if @poll_series.update(poll_series_params)
      flash[:success] = "Successfully updated poll series."
      redirect_to poll_series_index_path
    else
      render action: 'edit'
    end
    puts "error: #{@poll_series.errors.full_messages}"
  end

  def create
    is_public = true
    in_group_ids = "0"
    @poll_series = current_member.poll_series.new(poll_series_params)
    @poll_series.expire_date = Time.now + poll_series_params["expire_within"].to_i.days
    @poll_series.campaign_id = poll_series_params[:campaign_id].presence || 0

    if current_member.company?
      is_public = false
      in_group_ids = current_member.company.group.id.to_s
    end

    @poll_series.public = is_public
    @poll_series.in_group_ids = in_group_ids

    type_series = poll_series_params["type_series"]

    if type_series == "1"
      @poll_series.same_choices = params[:same_choices].delete_if {|choice| choice == "" }
    end

    if @poll_series.save
      flash[:success] = "Successfully created poll series."
      redirect_to poll_series_index_path
    else
      flash[:error] = @poll_series.errors.full_messages
      if poll_series_params["type_series"] == "0"
        render action: 'normal'
      else
        render action: 'same_choice'
      end
    end

    puts "error: #{@poll_series.errors.full_messages}"

  end

  def destroy
    @poll_series = PollSeries.find(params[:id])
    @poll_series.destroy
    flash[:success] = "Successfully destroyed poll series."
    redirect_to poll_series_index_path
  end


  private

  def set_poll_series
    @poll_series = PollSeries.find(params[:id])
  end

  def vote_params
    params.permit(:id, :member_id, :answer => [:id, :choice_id])
  end

  def poll_series_params
    params.require(:poll_series).permit(:expire_within, :campaign_id, :description, :member_id, :expire_date, :tag_tokens, :type_series, :same_choices => [], polls_attributes: [:id, :member_id, :title, :photo_poll, :_destroy, :choices_attributes => [:id, :poll_id, :answer, :_destroy]])
  end
end
