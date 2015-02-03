class WaitingList
  def initialize(member)
    @member = member
    @limit_member = Figaro.env.limit_member.to_i
  end

  def member_id
    @member.id
  end

  def get_info
    if check_waiting
      {
        waiting: true,
        your_waiting: your_waiting,
        behind_waiting: behind_waiting
      }
    else
      {
        waiting: false
      }
    end
  end

  private

  def check_waiting
    @member.waiting
  end

  def member_all
    Member.where(created_company: false).order('id asc').pluck(:id)
  end

  def member_count
    member_all.count
  end

  def remain_waiting_list
    @remain ||= member_all[@limit_member..member_count]
  end

  def your_waiting
    if remain_waiting_list.nil?
      0
    else
      remain_waiting_list.index(member_id) + 1
    end
  end
  
  def behind_waiting
    remain_waiting_list.count { |e| e > member_id }
  end
  
end