# class Comment
#   include Mongoid::Document
#   include Mongoid::Attributes::Dynamic
#   include Mongoid::Timestamps

#   field :poll_id, type: Integer
#   field :member_id, type: Integer
#   field :fullname, type: String
#   field :avatar, type: String
#   field :message, type: String
#   field :delete_status, type: Mongoid::Boolean, default: false


#   index( {poll_id: 1} )

#   WillPaginate.per_page = 10


# end
