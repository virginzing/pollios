class AddAccepterIdToRequestGroup < ActiveRecord::Migration
  def change
    add_column :request_groups, :accepter_id, :integer
    add_column :request_groups, :accepted, :boolean,  default: false
  end
end
