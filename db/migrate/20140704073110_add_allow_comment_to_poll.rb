class AddAllowCommentToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :allow_comment, :boolean, default: true
  end
end
