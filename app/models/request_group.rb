class RequestGroup < ActiveRecord::Base
  belongs_to :member
  belongs_to :group
end
