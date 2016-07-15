module Pollios::V2::CurrentMemberAPI
  class CampaignEntity < Pollios::V2::BaseEntity

    expose :id, as: :campaign_id

    expose :name 
    expose :description 
    expose :get_photo_campaign, as: :photo_campaign, if: -> (_, _) { campaign.get_photo_campaign.present? }
    expose :get_original_photo_campaign, as: :original_photo_campaign, if: -> (_, _) { campaign.get_original_photo_campaign.present? }
    expose :type_campaign, as: :type

    with_options(format_with: :as_integer) do
      expose :announce_on
      expose :expire
    end

    expose :owner
    expose :no_expiration

    expose :rewards do |_, _|
      Pollios::V2::Shared::RewardEntity.represent campaign.rewards, only: [:reward_id, :title, :detail, :total]
    end
    
    private

    def campaign
      object
    end

    def owner
      entity = Pollios::V1::PollAPI::MemberInPollEntity
      campaign.member.present? ? entity.represent(campaign.member) : entity.default_pollios_member
    end

    def no_expiration
      campaign.unexpired?
    end
    
  end
end