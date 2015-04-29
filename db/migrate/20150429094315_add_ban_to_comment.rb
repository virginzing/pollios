class AddBanToComment < ActiveRecord::Migration
  def change
    add_column :comments, :ban, :boolean, default: false
  end
end
