class AddCampaignIdToCollectionPollSeries < ActiveRecord::Migration
  def change
    add_reference :collection_poll_series, :campaign, index: true
  end
end
