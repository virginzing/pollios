class AddCompanyAdminToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :company_admin, :boolean,  default: false
  end
end
