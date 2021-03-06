class Trigger::Vote

  VOTE = "Vote"

  def initialize(member, poll, choice)
    @member = member
    @poll = poll
    @choice = choice
  end

  def triggerable
    @triggerable ||= @poll.triggers.first
  end

  def have_trigger?
    !!triggerable
  end

  def trigger!
    begin
    if have_trigger? && triggerable.data["action"] == VOTE
      triggerable.data["condition"].each do |condition|
        if (condition["choice_id"] == @choice.id) && (condition["group_id"] != 0)
          find_group = Group.find(condition["group_id"])

          # OH GOD WHY??? member voted poll have trigger! and system send invitation but why member add_friend_to_group by self

          Group.add_friend_to_group(find_group, @member, @member.id.to_s, sender_id: 0)
        end
      end
    end
    rescue => e
      puts "Trigger::Vote => #{e.message}"
    end
  end


end
