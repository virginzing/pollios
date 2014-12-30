class CreateBranchPollSeries < ActiveRecord::Migration
  def change
    create_table :branch_poll_series do |t|
      t.references :branch, index: true
      t.references :poll_series, index: true

      t.timestamps
    end
  end
end
