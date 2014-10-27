module PopularPoll
  module_function
  
  def in_total
    Poll.public_poll.active_poll.having_status_poll(:gray, :white).limit(3).where("vote_all != 0 AND series = 'f'").order("vote_all desc")
  end
  
end