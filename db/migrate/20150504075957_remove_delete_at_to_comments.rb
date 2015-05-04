class RemoveDeleteAtToComments < ActiveRecord::Migration
  def change
    remove_column :comments, :delete_status
  end
end
