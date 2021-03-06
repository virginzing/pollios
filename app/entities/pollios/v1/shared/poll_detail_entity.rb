module Pollios::V1::Shared
  class PollDetailEntity < Pollios::V1::BaseEntity
    
    expose :id, as: :poll_id
    expose :title
    expose :vote_all, as: :vote_count

    with_options(format_with: :as_integer) do
      expose :expire_date
      expose :created_at
    end

    # expose :get_vote_max, as: :vote_max, if: -> (_, _) { poll.vote_all > 0 }
    expose :get_choice_detail, as: :choices

    expose :choice_count
    expose :series
    expose :cached_tags, as: :tags

    expose :type_poll
    expose :poll_within

    expose :get_photo, as: :photo
    expose :thumbnail_type
    expose :allow_comment
    expose :comment_count
    expose :get_require_info, as: :require_info
    expose :get_creator_must_vote, as: :creator_must_vote
    expose :show_result
    expose :close_status
    expose :get_original_images, as: :original_images, if: -> (_, _) { poll.photo_poll.present? }

    expose :campaign, with: Pollios::V2::CurrentMemberAPI::CampaignEntity \
      , if: -> (_, _) { poll.get_campaign && member_reward.nil? }

    expose :member_reward, with: Pollios::V2::CurrentMemberAPI::MemberRewardInPollEntity \
      , if: -> (_, _) { poll.get_campaign && member_reward.present? }

    expose :creator do |_, _|
      Pollios::V1::PollAPI::MemberInPollEntity.represent creator
    end

    expose :member_states do
      expose :reported
      expose :bookmarked
      expose :saved_for_later
      expose :watching
      expose :voting
    end

    def poll
      object
    end
  
    def current_member
      @current_member ||= options[:current_member]
    end

    def member_states_ids
      options[:current_member_states]
    end

    def poll_inquiry_service
      @poll_inquiry_service ||= Member::PollInquiry.new(current_member, poll)
    end

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(current_member).social_linkage_ids
    end

    def thumbnail_type
      poll.thumbnail_type || 0
    end

    def poll_within
      poll_inquiry_service.feed_info
    end

    def member_reward
      member_reward = poll.get_reward_info(current_member, poll.campaign)
      member_reward == {} ? nil : member_reward
    end 

    def creator
      Member.cached_find(poll.member_id)
    end

    def reported
      member_states_ids[:reported_ids].include?(poll.id)
    end

    def bookmarked
      member_states_ids[:bookmarked_ids].include?(poll.id)
    end

    def saved_for_later
      member_states_ids[:saved_ids].include?(poll.id)
    end

    def watching
      member_states_ids[:watching_ids].include?(poll.id)
    end

    def voting
      poll_inquiry_service.voting_info
    end

  end
end