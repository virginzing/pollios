class MemberForDeleteSerializer < ActiveModel::Serializer
  self.root false
  attributes :id, :fullname, :email 
end
