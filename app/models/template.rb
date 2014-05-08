class Template
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  index "member_id" => 1

  field :member_id, type: Integer
  field :poll_template, type: Array


end
