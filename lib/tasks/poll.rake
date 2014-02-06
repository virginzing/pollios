namespace :poll do
  desc "Choice Count"
  task choice_count: :environment do
    Poll.all.each do |poll|
      poll.update(choice_count: poll.choices.count)
    end
  end

end
