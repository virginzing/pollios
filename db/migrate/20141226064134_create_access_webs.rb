class CreateAccessWebs < ActiveRecord::Migration
  def change
    create_table :access_webs do |t|
      t.references :member, index: true
      t.references :accessable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
