class LogVotePoll
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps
  include MemberHelper

  field :poll_id, type: Integer
  field :choice_id, type: Integer
  field :member_id, type: Integer
  field :member_type
  field :gender, type: Integer
  field :province
  field :birthday
  field :interests, type: Array
  field :salary
  

  index({ member_id: 1}, { name: "member_id_index"})
  index({ poll_id: 1})
  index({ choice_id: 1})

end
