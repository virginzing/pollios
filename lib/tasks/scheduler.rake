namespace :scheduler do
  desc "test log"
  task log: :environment do
    puts "DATABASE DATABASE"
    count_poll_current_year = Poll.get_poll_hourly
    puts "count => #{count_poll_current_year}"
  end


end
