class AddPollSeriesIdToCampaignMember < ActiveRecord::Migration
  def change
    add_reference :campaign_members, :poll_series, index: true
  end
end
