class SearchesController < ApplicationController
  before_action :set_current_member
  before_action :compress_gzip

  def users_and_groups
    init_request_search = Request::Search.new(@current_member, users_and_groups_params.except(:member_id))

    @groups = init_request_search.list_groups
    @next_cursor_group = init_request_search.next_cursor_group
    @total_list_groups = init_request_search.total_list_groups

    @members = init_request_search.list_members
    @next_cursor_member = init_request_search.next_cursor_member
    @total_list_members = init_request_search.total_list_members

    @is_friend = Friend.check_add_friend?(@current_member, @members, init_request_search.check_is_friend)

    TypeSearch.create_log_search_users_and_groups(@current_member, users_and_groups_params[:search])
  end

  def load_recent_search
    @recent_search_users_and_groups = TypeSearch.find_search_users_and_groups(@current_member)
  end

  def clear_search_users_and_groups
    @clear_search_users_and_groups = TypeSearch.clear_search_users_and_groups(@current_member)
    render status: @clear_search_users_and_groups ? :created : :unprocessable_entity
  end

  def clear_search_tags
    @clear_search_tags = TypeSearch.clear_search_tags(@current_member)
    render status: @clear_search_tags ? :created : :unprocessable_entity
  end

  private

  def users_and_groups_params
    params.permit(:member_id, :search, :next_cursor_member, :next_cursor_group)
  end

end
