class AddMaxCodeToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :max_invite_code, :integer,  default: 0
  end
end
