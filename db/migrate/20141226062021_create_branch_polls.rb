class CreateBranchPolls < ActiveRecord::Migration
  def change
    create_table :branch_polls do |t|
      t.references :poll, index: true
      t.references :branch, index: true

      t.timestamps
    end
  end
end
