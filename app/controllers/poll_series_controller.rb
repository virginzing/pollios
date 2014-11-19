class PollSeriesController < ApplicationController
  include PollSeriesHelper
  skip_before_action :verify_authenticity_token
  before_action :signed_user, only: [:index, :new, :normal, :same_choice]
  before_action :set_current_member, only: [:vote, :detail]
  before_action :set_poll_series, only: [:edit, :update, :destroy, :vote, :generate_qrcode, :detail]
  before_action :load_resource_poll_feed, only: [:detail]
  before_action :get_your_group, only: [:detail]

  def generate_qrcode

    # @qr = QrcodeSerializer.new(PollSeries.find(params[:id])).as_json.to_json
    @qr = get_link_for_qr_code(PollSeries.find(params[:id]))
    puts "#{@qr}"
    # deflate = Zlib::Deflate.deflate(qrurl)
    # base64_qrcode = Base64.urlsafe_encode64(deflate)

    # qrcode = URI.encode(qrurl)

    # @qr = RQRCode::QRCode.new( qrcode , :level => :l , size: 4)

    respond_to do |format|
      format.json
      format.html
      format.svg  { render :qrcode => @qr, :level => :h, :size => 4 }
      format.png  { render :qrcode => @qr, :level => :h, :unit => 4, layout: false }
      format.gif  { render :qrcode => @qr }
      format.jpeg { render :qrcode => @qr }
    end
  end

  def get_link_for_qr_code(poll_series)
    if Rails.env.production?
      "http://pollios.com/m/polls?" << "id=" << poll_series.qrcode_key << "&" << "series=true"
    else
      "http://localhost:3000/m/polls?" << "id=" << poll_series.qrcode_key << "&" << "series=true"
    end
  end

  def detail
    PollSeries.view_poll(@current_member, @poll_series)
    respond_to do |format|
      key = params[:key]

      if key.present?
        unless @poll_series.qrcode_key == key
          format.json { render json: { response_status: "ERROR", response_message: "Key is invalid" }, status: 403 }
        end
      end
      format.json
    end
  end

  def vote
    puts "#{vote_params}"
    @votes = @poll_series.vote_questionnaire(vote_params, @current_member, @poll_series)
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
    @group_list = current_member.company.groups if current_member.company?
  end

  def same_choice
    @poll_series = PollSeries.new
    2.times do
      @poll_series.polls.build
    end
    @group_list = current_member.company.groups if current_member.company?
  end

  def edit
    @poll_tags = @poll_series.tags
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
    @expire_date = poll_series_params["expire_date"].to_i

    @poll_series = current_member.poll_series.new(poll_series_params)
    @poll_series.expire_date = set_expire_date
    @poll_series.campaign_id = poll_series_params[:campaign_id].presence || 0

    @poll_series.allow_comment = poll_series_params[:allow_comment] == "on" ? true : false
    @poll_series.qr_only = poll_series_params[:qr_only] == "on" ? true : false
    @poll_series.require_info = poll_series_params[:require_info] == "on" ? true : false

    if current_member.company?
      is_public = false
      @poll_series.in_group = true
      @poll_series.in_group_ids = poll_series_params[:group_id]
    end

    @poll_series.public = is_public

    type_series = poll_series_params["type_series"]

    if type_series == "1"
      @poll_series.same_choices = params[:same_choices].delete_if {|choice| choice == "" }
    end

    if @poll_series.save
      @poll_series.in_group_ids.split(",").each do |group_id|
        PollSeriesGroup.create!(poll_series_id: @poll_series.id, group_id: group_id.to_i, member_id: current_member.id)
        ApnQuestionnaireWorker.perform_in(5.seconds, current_member.id, @poll_series.id, group_id) unless @poll_series.qr_only
      end
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
    Rails.cache.delete([current_member.id, 'my_questionnaire'])
    puts "error: #{@poll_series.errors.full_messages}"
  end

  def set_expire_date
    puts "@expire_date => #{@expire_date}"
    if @expire_date == 0
      return Time.zone.now + 100.years
    else
      return Time.zone.now + @expire_date.days
    end
  end

  def destroy
    @poll_series = PollSeries.find(params[:id])
    @poll_series.destroy
    flash[:success] = "Successfully destroyed poll series."
    redirect_to poll_series_index_path
  end


  private

  def set_poll_series
    begin
    @poll_series = PollSeries.find(params[:id])
    rescue => e
      respond_to do |wants|
        wants.json { render json: Hash["response_status" => "ERROR", "response_message" => e.message ] }
      end
    end
  end

  def vote_params
    params.permit(:id, :member_id, :suggest, :answer => [:id, :choice_id])
  end

  def poll_series_params
    params.require(:poll_series).permit(:group_id, :allow_comment, :expire_within, :campaign_id, :description, :member_id, :expire_date, :tag_tokens, :type_series, :qr_only, :require_info, :same_choices => [], polls_attributes: [:id, :member_id, :title, :photo_poll, :_destroy, :choices_attributes => [:id, :poll_id, :answer, :_destroy]])
  end
end
