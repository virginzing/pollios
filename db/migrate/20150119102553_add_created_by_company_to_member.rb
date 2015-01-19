class AddCreatedByCompanyToMember < ActiveRecord::Migration
  def change
    add_column :members, :created_company, :boolean,  default: false
  end
end
