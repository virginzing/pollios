class RequestCode < ActiveRecord::Base
  serialize :custom_properties, Hash
  
  belongs_to :member
end
