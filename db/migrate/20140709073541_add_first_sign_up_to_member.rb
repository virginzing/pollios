class AddFirstSignUpToMember < ActiveRecord::Migration
  def change
    add_column :members, :first_signup, :boolean, default: true
  end
end
