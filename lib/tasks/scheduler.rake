namespace :scheduler do
  desc "test recurring"
  task recurring: :environment do
    puts "poll recurring"
    poll = Poll.get_poll_hourly
    puts "count => #{poll.count}"
  end


end
