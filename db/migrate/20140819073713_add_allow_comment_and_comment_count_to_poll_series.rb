class AddAllowCommentAndCommentCountToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :allow_comment, :boolean,  default: true
    add_column :poll_series, :comment_count, :integer, default: 0
  end
end
