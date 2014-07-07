class AddCommentCountToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :comment_count, :integer,  default: 0
  end
end
