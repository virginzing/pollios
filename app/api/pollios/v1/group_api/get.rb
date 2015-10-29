module Pollios::V1::GroupAPI
  class Get < Grape::API
    version 'v1', using: :path

    resource :groups do

      desc "returns 10 groups"
      get do
        # gl = Group::ListMember.new(ActiveRecord::Base::Group.find(10))

        puts Module.nesting

        { groups: Group.limit(10) }
      end

    end

  end 
end