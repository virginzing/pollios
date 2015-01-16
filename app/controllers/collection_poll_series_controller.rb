class CollectionPollSeriesController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :signed_user
  before_action :load_company

  def edit
    @collection = CollectionPollSeries.find(params[:id])
  end

  def update
    @collection = CollectionPollSeries.find(params[:id])

    if @collection.update(collection_poll_series_params)
      flash[:success] = "Update Success"
      redirect_to feedback_questionnaires_path
    else
      flash[:error] = "Update Fail"
      render 'edit'
    end
  end




  private

  def collection_poll_series_params
    params.require(:collection_poll_series).permit(:id, :recurring_status, :feedback_status)
  end

end
