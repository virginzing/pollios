class CreateCollectionPollBranches < ActiveRecord::Migration
  def change
    create_table :collection_poll_branches do |t|
      t.references :branch, index: true
      t.references :collection_poll, index: true
      t.references :poll_series,  index: true
      t.timestamps
    end
  end
end
