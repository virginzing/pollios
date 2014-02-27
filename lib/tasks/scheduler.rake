namespace :scheduler do
  desc "test recurring"
  task recurring: :environment do
    puts "poll recurring test run"
    poll = Poll.get_poll_hourly
  end


end
