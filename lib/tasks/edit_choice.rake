namespace :edit_choice do
  desc "edit choice"
  task reset: :environment do
    choice = ["1-pick", "2-maybe pick", "3-maybe", "reject 4-reject"]
    count = 1
    PollSeries.last.polls.each do |poll|
      poll.choices.each do |c|
        c.update(answer: choice)
        count += 1
      end
    end
  end

end
