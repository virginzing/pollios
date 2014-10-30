class CreateActivityFeeds < ActiveRecord::Migration
  def change
    create_table :activity_feeds do |t|
      t.belongs_to :member, index: true
      t.string :action
      t.belongs_to :trackable, polymorphic: true, index: true
      t.belongs_to :group, index: true
      t.timestamps
    end
  end
end
