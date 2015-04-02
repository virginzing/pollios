module LimitPoll
  LIMIT_TIMELINE = 500
  LIMIT_POLL = 30

  module ClassMethods
    
  end
  
  module InstanceMethods
    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end