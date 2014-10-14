class Role < ActiveRecord::Base
  has_and_belongs_to_many :members, :join_table => :members_roles
  belongs_to :resource, :polymorphic => true
  
  scopify
end
