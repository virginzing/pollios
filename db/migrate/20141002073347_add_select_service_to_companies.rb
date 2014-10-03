class AddSelectServiceToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :select_service, :integer
    add_column :companies, :internal_poll, :integer,  default: 0
    
  end
end
