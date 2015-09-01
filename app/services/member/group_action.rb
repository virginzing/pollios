class Member::GroupAction

    def initialize(member, options = {})
        @member = member
        @options = options
    end

    def create(group_params = {})
        group = Group.new(
            member_id: @member.id,
            name: group_params[:name],
            group_type: :normal,                    # not sure about this, should generalize
            photo_group: group_params[:photo_group],
            description: group_params[:description],
            cover: group_params[:cover],
            cover_preset: group_params[:cover_preset],
            public: group_params[:public].to_b,
            admin_post_only: group_params[:admin_post_only].to_b,
            authorize_invite: :everyone,
            need_approve: group_params[:need_approve]
            )

        if group.save!
            set_group_cover(group_params[:cover])
            set_admin_of_group(group.id)
            group.create_group_company(company: @member.get_company) if @member.company.present?

            FlushCached::Member.new(@member).clear_list_groups

            invite(group, group_params[:friend_id])
        end

        return group
    end

    def invite(group, friend_ids, options = {})
        unless friend_ids
            return
        end

        member_ids = friend_ids.split(",").map(&:to_i)
        member_ids_to_invite = Group::ListMember.new(group).filter_non_members_from_list(member_ids)

        # TODO: Implement this logic.
        # unless member.company?
        #   unless group.system_group || group.public
        #     raise ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Group::NOT_ADMIN unless find_admin_group.include?(member_id)
        # end

        if member_ids_to_invite.size > 0
            members = Member.where(id: member_ids_to_invite)
            members.each do |friend|
                invite_member(group, friend)
            end

            FlushCached::Group.new(group).clear_list_members
            InviteFriendToGroupWorker.perform_async(@member.id, member_ids_to_invite, group.id, options) unless Rails.env.test?
        end
    end

private

    def members_not_in_group(group, member_list)
        return member_list - group.group_members.map(&:member_id)
    end

    # helper functions for #create
    def set_group_cover(cover)
        cover_group_url = ImageUrl.new(cover)
        if cover && cover_group_url.from_image_url?
            @group.update_column(:cover_preset, "0")
            @group.update_column(:cover, cover_group_url.split_cloudinary_url)
        end
    end

    def set_admin_of_group(group_id)
        @group.group_members.create(member_id: @member.id, is_master: true, active: true)
    end


    def invite_member(group, invitee)
        GroupMember.create(member_id: invitee.id, group_id: group.id, is_master: false, invite_id: @member.id, active: invitee.group_active)
        FlushCached::Member.new(invitee).clear_list_groups
    end
end
