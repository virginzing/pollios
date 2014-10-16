class CreateRequestGroups < ActiveRecord::Migration
  def change
    create_table :request_groups do |t|
      t.references :member, index: true
      t.references :group, index: true

      t.timestamps
    end
  end
end
