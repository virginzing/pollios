class DeletePoll
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :creator, type: Hash
  field :poll, type: Hash
  field :voter, type: Array
  field :delete_at, type: Time, default: -> { Time.now }



  def create_delete_poll(poll)
    
  end

end