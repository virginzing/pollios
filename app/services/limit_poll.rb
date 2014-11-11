module LimitPoll
  LIMIT_TIMELINE = 1000
  LIMIT_POLL = 20

  module ClassMethods
    
  end
  
  module InstanceMethods
    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end