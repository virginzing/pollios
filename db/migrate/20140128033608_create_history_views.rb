class CreateHistoryViews < ActiveRecord::Migration
  def change
    create_table :history_views do |t|
      t.references :member, index: true
      t.references :poll, index: true

      t.timestamps
    end
  end
end
