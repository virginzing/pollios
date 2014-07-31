class AddMemberIdToCompanies < ActiveRecord::Migration
  def change
    add_reference :companies, :member, index: true
  end
end
