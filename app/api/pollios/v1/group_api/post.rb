module Pollios::V1::GroupAPI
  class Post < Grape::API
    version 'v1', using: :path

    helpers do
      def group
        @group ||= group_or_nil       
      end

      def group_or_nil
        return nil unless params[:id].present?
        Group.cached_find(params[:id])
      end

      def current_member_group_action
        @current_member_group_action ||= Member::GroupAction.new(current_member, group)
      end
    end

    resource :groups do
      desc 'create a new group'
      params do
        requires :name, type: String, desc: 'group name'
        optional :description, type: String, desc: 'group description'
        optional :cover_preset, type: Integer, desc: 'group cover preset id'
        optional :cover, type: String, desc: 'group cover url'
        optional :friend_ids, type: Array[Integer], desc: 'list of friend (ids) to invite to group after created'

        exactly_one_of :cover_preset, :cover
      end
      post do
        current_member_group_action.create(params)
      end

      desc 'join group with secret code'
      params do
        requires :code, type: String, desc: 'secret code'
      end
      post '/join_with_secret_code' do
        current_member_group_action.join_with_secret_code(params[:code])
      end

      params do
        requires :id, type: Integer, desc: 'group id'
      end
      route_param :id do

        desc 'leave group'
        post '/leave' do
          current_member_group_action.leave
        end

        desc 'join group'
        post '/join' do
          current_member_group_action.join
        end

        resource :request do
          desc 'cancel outgoing group request'
          post '/cancel' do
            current_member_group_action.cancel_request
          end

          desc 'accept group invitation'
          post '/accept' do
            current_member_group_action.accept_invitation
          end

          desc 'reject group invitation'
          post '/reject' do
            current_member_group_action.reject_invitation
          end
        end

        resource :members do
          desc 'invite friends to group'
          params do
            requires :friend_ids, type: Array[Integer], desc: 'list of friend id invite to group'
          end
          post '/invite' do
            current_member_group_action.invite(params[:friend_ids])
          end

          params do
            requires :a_member_id, type: Integer, desc: 'member id in group'
          end

          route_param :a_member_id do

            helpers do
              def a_member
                @a_member ||= Member.cached_find(params[:a_member_id])
              end

              def current_member_group_member_action
                @current_member_group_member_action ||= Member::GroupAdminAction.new(current_member, group, a_member)
              end
            end

            desc 'poke invited friend to group'
            post '/poke' do
              current_member_group_action.poke_invited(a_member)
            end

            desc "cancel member's friend invite to join group"
            post '/cancel' do
              current_member_group_action.cancel_invite(a_member)
            end

            desc "approve member's request to join group"
            post '/approve' do
              current_member_group_member_action.approve
            end

            desc "deny member's request or being invited to join group"
            post '/deny' do
              current_member_group_member_action.deny
            end

            desc 'remove member from group'
            post '/remove' do
              current_member_group_member_action.remove
            end

            desc 'promote member to group administrator'
            post '/promote' do
              current_member_group_member_action.promote
            end

            desc 'demote member from administrator'
            post '/demote' do
              current_member_group_member_action.demote
            end
          end
        end
        
      end
    end

  end
end