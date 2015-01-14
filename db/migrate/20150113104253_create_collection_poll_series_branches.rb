class CreateCollectionPollSeriesBranches < ActiveRecord::Migration
  def change
    create_table :collection_poll_series_branches do |t|
      t.references :collection_poll_series
      t.references :branch, index: true
      t.references :poll_series, index: true

      t.timestamps
    end

    add_index :collection_poll_series_branches, :collection_poll_series_id, name: 'by_series_and_branch'
  end
end