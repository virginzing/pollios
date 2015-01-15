class AddMainPollSeiresIdToCollectionPollSeries < ActiveRecord::Migration
  def change
    add_column :collection_poll_series, :main_poll_series, :string, array: true, default: '{}'
  end
end
