class Member::GroupService

    def initialize(member, options = {})
        @member = member
        @options = options
    end

    def create(group_params = {})
        @group = Group.new(
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

        if @group.save!
            set_group_cover(group_params[:cover])
            set_admin_of_group(@group.id)
            @group.create_group_company(company: @member.get_company) if @member.company.present?

            FlushCached::Member.new(@member).clear_list_groups

            invite(@group, group_params[:friend_id])
        end

        return @group
    end

    def invite(group, friend_ids)
        if friend_ids
        end
    end

    private

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
end
