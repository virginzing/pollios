module WebPanel
  class GroupsController < ApplicationController

    def load_group
      @group = Group.cached_find(params[:group_id])
      render layout: false
    end

    def group_update
      group_id = group_update_params[:id]
      member_id = group_update_params[:pk]
      taker_id = group_update_params[:taker_id]
      @admin_status = group_update_params[:value] == "1" ? false : true

      find_member_in_group = GroupMember.where("member_id = ? AND group_id = ?", member_id, group_id).first
      find_member = find_member_in_group.member

      taker = Member.cached_find(taker_id)

      respond_to do |format|
        if find_member_in_group.present?
          find_group = find_member_in_group.group

          if find_group.company? ## Is it group of company?
            find_role_member = find_member.roles.first

            if find_role_member.present?
              find_exist_role_member = find_role_member.resource.get_company
            end

            if find_role_member.nil? || (find_exist_role_member.id == find_group.get_company.id)
              find_member_in_group.update!(is_master: @admin_status)

              if @admin_status
                find_member.add_role :group_admin, find_group
              else
                find_member.remove_role :group_admin, find_group
              end
            else
              format.json { render text: "You have already admin of other Company" , status: :unprocessable_entity }
            end

          else
            find_member_in_group.update!(is_master: @admin_status)
          end

          if @admin_status
            GroupActionLog.create_log(find_group, taker, find_member, "promote_admin")
          else
            GroupActionLog.create_log(find_group, taker, find_member, "degrade_admin")
          end

          FlushCached::Member.new(find_member).clear_list_groups
          FlushCached::Group.new(find_group).clear_list_members

          format.json { render json: [
                {value: 1, text: 'Member'},
                {value: 2, text: 'Admin'}
        ], root: false }
        else
          format.json { render text: "Unable update record." , status: :unprocessable_entity }
        end
      end
    end

    def delete_photo_group
      Group.transaction do
        begin
          find_group = Group.find(params[:id])
          find_group.remove_photo_group!
          find_group.save
          flash[:success] = "Delete photo group successfully."
        rescue => e
          flash[:error] = e.message
        end

        respond_to do |format|
          format.html { redirect_to company_edit_group_path(find_group) }
        end
      end
    end

    def delete_cover_group
      Group.transaction do
        begin
          find_group = Group.find(params[:id])
          find_group.remove_old_cover
          find_group.save!
          flash[:success] = "Delete cover group successfully."
        rescue => e
          flash[:error] = e.message
        end

        respond_to do |format|
          format.html { redirect_to(:back) }
        end
      end
    end

    private

    def group_update_params
      params.permit(:pk, :id, :value, :taker_id)
    end

  end
end
