class Trigger::BuildTrigger
  def initialize(params)
    @params = params
  end

  def poll
    Poll.cached_find(@params["poll_id"])
  end

  def choice_with_group_id
    list = []

    @params["choice"].each do |k, v|
      list << Hash["choice_id" => k.to_i, "group_id" => v.to_i ]
    end

    list
  end

  def poll_as_json
    hash = {}
    hash.merge!(@params["triggers"]["data"])
    hash.merge!({
      poll_id: @params["poll_id"]
    })
    hash.merge!({
      condition: choice_with_group_id
    })
    hash
  end

  def setup
    Trigger.transaction do

      trigger = Trigger.create!(triggerable: poll, data: poll_as_json)

      if trigger
        @params["choice"].each do |choice_id, group_id|
          if group_id.present?
            list_members_voted_as_str = find_members_from_history_votes(choice_id)
            Group.add_friend_to_group(Group.find(group_id), Group.find(group_id).member, list_members_voted_as_str)
          end
        end
      end
    end
  end

  def find_members_from_history_votes(choice_id)
    HistoryVote.where(poll_id: poll.id, choice_id: choice_id).map(&:member_id).join(",")
  end
end
