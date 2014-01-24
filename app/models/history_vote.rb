class HistoryVote
  include Mongoid::Document
  
  field :member_id, type: Integer
  field :poll_id, type: Integer
  field :choice_id, type: Integer
end
