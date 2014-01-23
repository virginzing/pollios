class AddPhotoPollToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :photo_poll, :string
  end
end
