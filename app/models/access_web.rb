class AccessWeb < ActiveRecord::Base
  belongs_to :member
  belongs_to :accessable, polymorphic: true

end
