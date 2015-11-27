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

        desc 'ask to join group'
        post '/join' do

        end

        desc 'leave group'
        post '/leave' do

        end

        resource :request do
          desc 'accept request to join group'
          post '/accept' do

          end

          desc 'reject request to join group'
          post '/reject' do

          end

          desc 'cancel invite friend to group'
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

            desc 'admin approve request to join group'
            post '/approve' do

            end

            desc 'admin deny request to join group'
            post '/deny' do

            end

            desc 'admin remove member in group'
            post '/remove' do

            end

            desc 'creator promote member in group to member'
            post '/promote' do

            end

            desc 'creator demote member in group to member'
            post '/demote' do

            end
          end
        end
        
      end
    end

  end
end