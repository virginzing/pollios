class UnSeePoll < ActiveRecord::Base
  belongs_to :member
  belongs_to :unseeable, polymorphic: true

end
