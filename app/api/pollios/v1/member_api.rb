module Pollios::V1
  class MemberAPI < Grape::API
    version 'v1', using: :path
    desc "Member API"

    resource :members do

      params do
        requires :id, type: Integer, desc: "member id"
      end

      route_param :id do

        desc "returns member detail for profile screen of member"
        get do
          { member: Member.find(params[:id]) }
        end

      end 
    end 

  end
end 