module Pollios::V1::Shared
  class PollDetailEntity < Pollios::V1::BaseEntity
    
    expose :id, as: :poll_id
    expose :title
    expose :vote_all, as: :vote_count

    with_options(format_with: :as_integer) do
      expose :expire_date
      expose :created_at
    end

    expose :get_vote_max, as: :vote_max, if: -> (_, _) { poll.vote_all > 0 }
    expose :get_choice_detail, as: :choices

    expose :choice_count
    expose :series
    expose :cached_tags, as: :tags

    expose :public, as: :is_public
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

    expose :campaign, with: Pollios::V1::CurrentMemberAPI::CampaignDetailEntity, if: -> (_, _) { poll.get_campaign }

    expose :creator do |_, _|
      Pollios::V1::Shared::MemberEntity.represent creator, current_member_linkage: current_member_linkage
    end

    expose :member_states do
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

    def poll_list_service
      @poll_list_service ||= Member::PollList.new(current_member)
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

    def voting
      poll_list_service.voting_detail(poll.id)
    end

    def poll_within
      # TODO: Make a proper service method in Poll::Listing
      poll.feed_name_for_member(current_member)
    end

    def creator
      Member.cached_find(poll.member_id)
    end

    def bookmarked
      poll_inquiry_service.bookmarked?
    end

    def saved_for_later
      poll_inquiry_service.saved_for_later?
    end

    def watching
      poll_inquiry_service.watching?
    end

  end
end