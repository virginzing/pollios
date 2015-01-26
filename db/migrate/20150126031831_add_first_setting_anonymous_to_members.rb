class AddFirstSettingAnonymousToMembers < ActiveRecord::Migration
  def change
    add_column :members, :first_setting_anonymous, :boolean,  default: true
  end
end
