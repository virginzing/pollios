class WhichPoll

  WHERE = {
    :public => 0,
    :friend_following => 1,
    :group => 2
  }

  def self.to_hash(value = nil)
    case value
      when 0 then Hash["in" => "Public"]
      when 1 then Hash["in" => "Friends & Following"]
      when 2 then Hash["in" => "Group"]
    end
  end

end
