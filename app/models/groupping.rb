class Groupping < ActiveRecord::Base
  belongs_to :collection_poll
  belongs_to :groupable, polymorphic: true

end
