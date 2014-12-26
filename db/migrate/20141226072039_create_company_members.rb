class CreateCompanyMembers < ActiveRecord::Migration
  def change
    create_table :company_members do |t|
      t.references :company, index: true
      t.belongs_to :member

      t.timestamps
    end
    add_index :company_members, :member_id, unique: true
  end
end
