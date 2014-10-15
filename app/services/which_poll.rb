class WhichPoll

  WHERE = {
    0 => :public,
    1 => :friend_and_following,
    2 => :group
  }

  def self.to_hash(value = nil)
    case value
      when 0 then Hash["in" => "Public"]
      when 1 then Hash["in" => "Friend & Following"]
      when 2 then Hash["in" => "Group"]
    end
  end

end
