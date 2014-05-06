class AddApiTokenToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :api_token, :string
  end
end
