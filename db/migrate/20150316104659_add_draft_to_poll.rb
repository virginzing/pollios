class AddDraftToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :draft, :boolean,  default: false
  end
end
