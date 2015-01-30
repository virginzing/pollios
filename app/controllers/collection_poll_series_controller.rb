class CollectionPollSeriesController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :signed_user
  before_action :load_company

  def edit
    @collection = CollectionPollSeries.find(params[:id])
  end

  def update
    @collection = CollectionPollSeries.find(params[:id])

    @collection.campaign_id = collection_poll_series_params[:campaign_id]

    if @collection.campaign_id_changed?
      @questionnaire_ids = @collection.collection_poll_series_branches.pluck(:poll_series_id)
      @questionnaires = PollSeries.joins(:branch)
                                .where("branch_poll_series.branch_id IN (?) AND poll_series.id IN (?)", @company.branches.map(&:id), @questionnaire_ids)
      @questionnaires.update_all(campaign_id: @collection.campaign_id)  
    end

    if @collection.update(collection_poll_series_params.except(:company_id))

      flash[:success] = "Update Success"
      redirect_to feedback_questionnaires_path
    else
      flash[:error] = "Update Fail"
      render 'edit'
    end
  end


  private

  def collection_poll_series_params
    params.require(:collection_poll_series).permit(:id, :recurring_status, :feedback_status, :campaign_id, :company_id)
  end

end
