class AddProvinceToMember < ActiveRecord::Migration
  def change
    add_reference :members, :province, index: true
  end
end
