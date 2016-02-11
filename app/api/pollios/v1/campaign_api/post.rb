module Pollios::V1::CampaignAPI
  class Post < Grape::API
    version 'v1', using: :path

    resource :campaigns do
      
      helpers do
        def campiagn_creation
          campiagn_creation = Member::CampaignAction.new(current_member)
        end
      end

      desc '[x] create new campaign'
      params do
        requires :name, type: String, desc: 'campaign name'
        requires :type, type: String, desc: 'campaign description'

        optional :photo, type: String, desc: 'campaign photo'
        optional :end_sample, type: Integer, desc: 'campaign end_sample'
        optional :announce_on, type: DateTime, desc: 'campaign announce_on'
        optional :reward_expire, type: DateTime, desc: 'campaign reward_expire'
        optional :expire_at, type: DateTime, desc: 'campaign expire_at'

        requires :rewards, type: Array[Hash], desc: 'campaign rewards list' do
          requires :rewards, type: Hash, desc: 'reward for campaign' do
            requires :title, type: String, desc: 'reward title'
            optional :detail, type: String, desc: 'reward deetail'
            requires :total, type: Integer, desc: 'reward amount'
            requires :odds, type: Integer, desc: 'reward odds'
            requires :redeem_instruction, type: String, desc: 'reward redeem instruction'
            requires :self_redeem, type: Boolean, desc: 'true if can redeem reward by self'
            optional :reward_expire, type: DateTime, desc: 'reward expire'
            optional :expire_at, type: DateTime, desc: 'reward expire_at'
          end
        end
      end
      post do
        params
        # campiagn_creation.create(params)
      end
    end

  end
end