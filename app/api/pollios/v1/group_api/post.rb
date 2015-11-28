module Pollios::V1::GroupAPI
  class Post < Grape::API
    version 'v1', using: :path

    helpers do
      def group
        @group ||= Group.cached_find(params[:id])       
      end

      def curent_member_action
        @curent_member_action ||= Member::GroupAction.new(current_member)
      end
    end

    resource :groups do
      desc 'create group by current member'
      params do
        requires :name, type: String, desc: 'group name'
        optional :description, type: String, desc: 'group description'
        optional :cover_preset, type: String, desc: 'group cover preset'
        optional :cover, type: String, desc: 'group cover url'
        optional :friend_ids, type: Array[Integer], desc: 'list of friend id add to group after created'

        exactly_one_of :cover_preset, :cover
      end
      post do

      end

      params do
        requires :id, type: Integer, desc: 'group id'
      end

      route_param :id do

        desc 'request to join group'
        post '/join' do

        end

        desc 'leave group'
        post '/leave' do

        end

        resource :request do
          desc 'accept group invitation'
          post '/accept' do

          end

          desc 'reject group invitation'
          post '/reject' do

          end

          desc 'cancel outgoing group request'
          post '/cancel' do

          end
        end

        resource :members do
          desc 'invite friends to group'
          params do
            requires :friend_ids, type: Array[Integer], desc: 'list of friend id invite to group'
          end
          post '/invite' do

          end

          params do
            requires :id, type: Integer, desc: 'member id in group'
          end

          route_param :id do

            desc "approve member's request to join group"
            post '/approve' do

            end

            desc "deny member's request to join group"
            post '/deny' do

            end

            desc 'remove member from group'
            post '/remove' do

            end

            desc 'promote member to group administrator'
            post '/promote' do

            end

            desc 'demote member from administrator'
            post '/demote' do

            end
          end
        end
        
      end
    end

  end
end