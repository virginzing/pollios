module Pollios::V1::GroupAPI
  class Put < Grape::API
    version 'v1', using: :path

    resource :groups do

      helpers do

        def group
          @group = Group.cached_find(params[:id])
        end

        def current_member_group_setting
          @current_member_group_setting = Member::GroupUpdate.new(current_member, group)
        end
      end

      params do
        requires :id, type: Integer, desc: 'group id'
      end

      route_param :id do
        resource :settings do

          desc 'update group details'
          params do
            optional :name, type: String, desc: "new group's name"
            optional :description, type: String, desc: "new group's description"
            optional :cover_preset, type: Integer, desc: "new group's cover preset id"
            optional :cover, type: String, desc: "new group's cover URL"

            mutually_exclusive :cover_preset, :cover
          end
          put '/details' do
            update_details = current_member_group_setting.details(params)
            present update_details, with: Pollios::V1::Shared::GroupEntity
          end

          desc 'update group privacy (true is turn on privacy)'
          params do
            requires :public, type: Boolean, desc: 'can searchable'
            requires :need_approve, type: Boolean, desc: 'require approval for joining'
            requires :opened, type: Boolean, desc: 'show poll for member outside group'

            optional :public_id, type: String, desc: "group's public_id"
          end
          put '/privacy' do
            update_privacy = current_member_group_setting.privacy(params)
            present update_privacy, with: PrivacyEntity, current_member: current_member
          end
        end
      end
    end

  end
end