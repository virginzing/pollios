class AddAddressAndTelephoneNumberToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :address, :string
    add_column :companies, :telephone_number, :string
  end
end
