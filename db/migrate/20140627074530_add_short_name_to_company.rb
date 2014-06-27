class AddShortNameToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :short_name, :string, default: 'CA'
  end
end
