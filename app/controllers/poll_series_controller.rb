class PollSeriesController < ApplicationController
  include PollSeriesHelper
  skip_before_action :verify_authenticity_token
  before_action :signed_user, only: [:index, :new]
  before_action :set_poll_series, only: [:edit, :update, :destroy]

  def index
    @series = @current_member.poll_series.paginate(page: params[:page])
  end

  def new
    @poll_series = PollSeries.new
    1.times do
      poll = @poll_series.polls.build
      2.times { poll.choices.build }
    end
  end

  def edit
    @poll_tags = @poll_series.tags
    puts "polltag = #{@poll_tags}"
  end

  def update
    if @poll_series.update(poll_series_params)
      flash[:notice] = "Successfully updated poll series."
      redirect_to poll_series_index_path
    else
      render action: 'edit'
    end
    puts "error: #{@poll_series.errors.full_messages}"
  end

  def create
    puts params
    @poll_series = current_member.poll_series.new(poll_series_params)
    type_series = poll_series_params["type_series"]

    if type_series == "1"
      @poll_series.same_choices = params[:same_choices].delete_if {|choice| choice == "" }
    end

    if @poll_series.save
      flash[:notice] = "Successfully created poll series."
      redirect_to poll_series_index_path
    else
      render action: 'new'
    end
    
    puts "error: #{@poll_series.errors.full_messages}"

  end

  def destroy
    @poll_series = PollSeries.find(params[:id])
    @poll_series.destroy
    flash[:notice] = "Successfully destroyed poll series."
    redirect_to poll_series_index_path
  end


  private

  def set_poll_series
    @poll_series = PollSeries.find(params[:id])
  end

  def poll_series_params
    params.require(:poll_series).permit(:campaign_id, :description, :member_id, :expire_date, :tag_tokens, :type_series, :same_choices => [], polls_attributes: [:id, :member_id, :title, :_destroy, :choices_attributes => [:id, :poll_id, :answer, :_destroy]])
  end
end
