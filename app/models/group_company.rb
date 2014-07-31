class GroupCompany < ActiveRecord::Base
  belongs_to :group
  belongs_to :company
end
