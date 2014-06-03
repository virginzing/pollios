class RenamePublishToPublicOfGroup < ActiveRecord::Migration
  def change
    rename_column :groups, :publish, :public
  end
end
