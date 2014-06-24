module LimitPoll
  LIMIT_TIMELINE = 3000
  LIMIT_POLL = 50

  module ClassMethods
    
  end
  
  module InstanceMethods
    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end