class AddExpireStatusToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :expire_status, :boolean,  default: false
  end
end
