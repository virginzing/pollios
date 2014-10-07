class DeletePollSerializer < ActiveModel::Serializer
  attributes :id, :creator, :poll, :voter, :delete_at
end
