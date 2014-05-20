class NotifyLog < ActiveRecord::Base
  serialize :custom_properties, Hash

  self.per_page = 10

  belongs_to :recipient, class_name: 'Member'
  belongs_to :sender, class_name: 'Member'
end
