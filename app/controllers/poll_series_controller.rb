class PollSeriesController < ApplicationController
  include PollSeriesHelper
  skip_before_action :verify_authenticity_token
  before_action :signed_user, only: [:index, :new, :normal, :same_choice]
  before_action :set_current_member, only: [:vote, :detail, :un_see, :save_later, :un_save_later]
  before_action :set_poll_series, only: [:questionnaire_detail, :edit, :update, :destroy, :vote, :generate_qrcode, :detail, :un_see, :save_later, :un_save_later]
  before_action :load_resource_poll_feed, only: [:detail]
  before_action :get_your_group, only: [:detail]

  before_action :set_company, only: [:same_choice, :normal]
  def generate_qrcode

    # @qr = QrcodeSerializer.new(PollSeries.find(params[:id])).as_json.to_json
    # @qr = get_link_for_qr_code(PollSeries.find(params[:id]))
    # puts "#{@qr}"
    @qr = GenerateQrcodeLink.new(PollSeries.find(params[:id])).get_link
    # deflate = Zlib::Deflate.deflate(qrurl)
    # base64_qrcode = Base64.urlsafe_encode64(deflate)

    # qrcode = URI.encode(qrurl)

    # @qr = RQRCode::QRCode.new( qrcode , :level => :l , size: 4)

    # respond_to do |format|
    #   format.json
    #   format.html
    #   format.svg  { render :qrcode => @qr, :level => :h, :size => 4 }
    #   format.png  { render :qrcode => @qr, :level => :h, :unit => 4, layout: false }
    #   format.gif  { render :qrcode => @qr }
    #   format.jpeg { render :qrcode => @qr }
    # end

    respond_to do |format|
      format.html
    end
  end

  def un_see
    @un_see_questionnaire = UnSeePoll.new(member_id: @current_member.id, unseeable: @poll_series)
    begin
      @un_see_questionnaire.save
      render :status => :created
    rescue => e
      @un_see_questionnaire = nil
      @response_message = "You already save to unsee questionnaires"
      render :status => :unprocessable_entity
    end
  end

  def save_later
    @save_later = SavePollLater.new(member_id: @current_member.id, savable: @poll_series)
    begin
      @save_later.save
      render status: :created
    rescue => e
      @save_later = nil
      @response_message = "You already save for latar"
      render status: :unprocessable_entity
    end
  end

  def un_save_later
    @un_save_later = SavePollLater.find_by(member_id: @current_member.id, savable: @poll_series)

    if @un_save_later.destroy
      render status: :created
    else
      render status: :unprocessable_entity
    end  
  end

  def detail
    PollSeries.view_poll(@current_member, @poll_series)

    if @poll_series.feedback
      @collection_poll_series_branch = CollectionPollSeriesBranch.where(collection_poll_series_id: @poll_series.collection_poll_series.id, branch_id: @poll_series.branch.id).order("created_at desc").first
      @poll_series = @collection_poll_series_branch.poll_series
    end
    # respond_to do |format|
    #   key = params[:qr_key]

    #   if key.present?
    #     unless @poll_series.qrcode_key == key
    #       format.json { render json: { response_status: "ERROR", response_message: "Key is invalid" }, status: :unprocessable_entity }
    #     end
    #   end
    #   format.json
    # end
  end

  def vote
    options = params[:data_options]
    @votes = @poll_series.vote_questionnaire(vote_params, @current_member, @poll_series, options)

    if @votes.present?
      if @poll_series.get_campaign
        @reward = @poll_series.find_campaign_for_predict?(@current_member)
      end 
    end

  end

  def index
    @poll_series = current_member.poll_series.paginate(page: params[:page])
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
    @group_list = current_member.get_company.groups if current_member.get_company.present?
  end

  def same_choice
    @poll_series = PollSeries.new
    2.times do
      @poll_series.polls.build
    end
    @group_list = current_member.get_company.groups if current_member.get_company.present?
  end

  def show
    @poll_series = PollSeries.find(params[:id])
    # puts "#{GenerateQrcodeLink.new(@poll_series).get_redirect_link}"
    @qr = RQRCode::QRCode.new(GenerateQrcodeLink.new(@poll_series).get_redirect_link, :size => 8, :level => :h ).to_img.resize(200, 200).to_data_url
  end

  def get_link_for_qr_code_series
    if Rails.env.production?
      "http://pollios.com/qrcode?key=" << secret_qrcode_key
    else
      "http://192.168.1.18:3000/qrcode?key=" << secret_qrcode_key
    end
  end

  def secret_qrcode_key
    string = "id=" + @poll_series.qrcode_key + "&s=t"
    Base64.urlsafe_encode64(string)
  end

  def questionnaire_detail
    @poll_series = @poll_series.decorate
    @array_list = []

    @poll_series.polls.each do |poll|
      @array_list << poll.choices.collect!{|e| e.answer.to_i * e.vote.to_f }.reduce(:+).round(2)
    end

    @qr = RQRCode::QRCode.new(GenerateQrcodeLink.new(@poll_series).get_redirect_link, :size => 8, :level => :h ).to_img.resize(200, 200).to_data_url
  end

  def edit

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
    PollSeries.transaction do
      # is_public = true
      @expire_date = poll_series_params["expire_date"].to_i

      @poll_series = current_member.poll_series.new(PollSeries::WebForm.new(@current_member, poll_series_params).new_params)

      puts "new params => #{PollSeries::WebForm.new(@current_member, poll_series_params).new_params}"
      @poll_series.expire_date = set_expire_date
      @poll_series.campaign_id = poll_series_params[:campaign_id].presence || 0

      unless @poll_series.public
        # is_public = false
        @poll_series.in_group = true
        @poll_series.in_group_ids = "0"
        @poll_series.in_group_ids = poll_series_params[:group_id].select{|e| e if e.present? }.join(",")
      end

      # @poll_series.public = is_public

      type_series = poll_series_params["type_series"]

      if type_series == "1"
        @poll_series.same_choices = params[:same_choices].delete_if {|choice| choice == "" }
      end

      if @poll_series.save
        PollSeriesCompany.create_poll_series(@poll_series, current_member.get_company, :web)
        
        if @poll_series.in_group
          @poll_series.in_group_ids.split(",").each do |group_id|
            PollSeriesGroup.create!(poll_series_id: @poll_series.id, group_id: group_id.to_i, member_id: current_member.id)    
          end
        end
        flash[:success] = "Successfully created poll series."
        redirect_to company_questionnaires_path
      else
        flash[:error] = @poll_series.errors.full_messages
        if poll_series_params["type_series"] == "0"
          render action: 'normal'
        else
          flash[:error] = "Something went wrong"
          redirect_to same_choice_questionnaire_path
        end
      end
      Rails.cache.delete([current_member.id, 'my_questionnaire'])
      puts "error: #{@poll_series.errors.full_messages}"
    end
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
    redirect_to company_questionnaires_path
  end


  private

  def set_poll_series
    @poll_series = PollSeries.cached_find(params[:id])
  end

  def set_company
    @company = current_member.company || current_member.company_member.company
  end

  def vote_params
    params.permit(:id, :member_id, :suggest, :answer => [:id, :choice_id])
  end

  def poll_series_params
    params.require(:poll_series).permit(:allow_comment, :expire_within, :feedback, :campaign_id, :description, :member_id, :expire_date, :public, :tag_tokens, :type_poll, :type_series, :qr_only, :require_info, :group_id => [],:same_choices => [], polls_attributes: [:id, :member_id, :title, :photo_poll, :type_poll, :_destroy, :choices_attributes => [:id, :poll_id, :answer, :_destroy]])
  end
end
