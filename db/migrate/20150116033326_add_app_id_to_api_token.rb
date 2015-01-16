class AddAppIdToApiToken < ActiveRecord::Migration
  def change
    add_column :api_tokens, :app_id, :string
    remove_column :api_tokens, :uuid
  end
end
