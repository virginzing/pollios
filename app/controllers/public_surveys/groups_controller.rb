class PublicSurveys::GroupsController < ApplicationController

  before_action :only_public_survey
  before_action :set_group, only: [:show, :edit, :update, :destroy, :remove_member]

  expose(:group) { @group.decorate }

  def index
    @groups = Group.only_public.without_deleted.eager_load(:group_company, :poll_groups, :group_members)
                    .where("group_companies.company_id = #{current_company.id}").uniq
  end

  def new
    @group = Group.new
    @members = Company::ListMember.new(current_company).get_list_members
  end

  def create
    @init_group_company = CreateGroupCompany.new(current_member, current_company, group_params, params[:list_member])
    @group = @init_group_company.create_group
    FlushCached::Member.new(current_member).clear_list_groups

    respond_to do |wants|
      if @group
        flash[:success] = "Successfully created group."
        wants.html { redirect_to public_survey_groups_path }
      else
        flash[:error] = "Error"
        wants.html { render 'new' }
      end
    end
  end

  def show
    init_poll = Company::Groups::ListPolls.new(@group)
    @polls = init_poll.all

    @member_all = Group::ListMember.new(@group)
    @members = @member_all.active
    @members_inactive = @member_all.pending
    @list_surveyor = @group.surveyor
    @members_request = @group.members_request

    @activity_feeds = ActivityFeed.includes(:member, :trackable).where(group_id: @group.id).order("created_at desc").paginate(page: params[:page], per_page: 10)
  end

  def update
    respond_to do |format|
      group = @group

      if group_params[:cover]
        group.cover_preset = "0"
      elsif group_params[:cover_preset]
        group.remove_old_cover
      else
        group.need_approve = group_params[:need_approve].present? ? true : false
        group.opened = group_params[:opened].present? ? true : false
      end

      if group.update(group_params)

        group.members.each do |member|
          FlushCached::Member.new(member).clear_list_groups
        end

        flash[:success] = "Successfully updated group."
        format.html { redirect_to public_survey_group_path(group) }
      else
        @error_message = @current_member.errors.messages
        format.html { redirect_to edit_public_survey_group_path(group) }
      end
    end
  end

  def destroy

  end

  def remove_member
    @remove_member = Group.leave_group(Member.cached_find(params[:member_id]), @group)

    respond_to do |format|
      if @remove_member
        flash[:success] = "Successfully removed member."
      else
        flash[:error] = "Error"
      end
      format.html { redirect_to public_survey_group_path(@group) }
    end
  end

  def new_poll
    @poll = Poll.new
    @group_list = Company::ListGroup.new(current_company).public_group
  end

  private

  def set_group
    @group = Group.cached_find(params[:id])
    raise ExceptionHandler::Forbidden unless Company::ListGroup.new(current_company).access_group?(@group)
  end

  def group_params
    params.require(:group).permit(:name, :description, :photo_group, :cover, :public, :leave_group, :admin_post_only, :system_group, :need_approve, :set_group_type, :opened)
  end


end
