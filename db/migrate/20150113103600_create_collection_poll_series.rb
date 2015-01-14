class CreateCollectionPollSeries < ActiveRecord::Migration
  def change
    create_table :collection_poll_series do |t|
      t.string :title
      t.references :company, index: true
      t.integer :sum_view_all,  default: 0
      t.integer :sum_vote_all,  default: 0
      t.string :questions, array: true, default: '{}'
      t.timestamps
    end
  end
end