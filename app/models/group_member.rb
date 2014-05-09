class GroupMember < ActiveRecord::Base
  include GroupMemberHelper
  
  belongs_to :member
  belongs_to :group
end
