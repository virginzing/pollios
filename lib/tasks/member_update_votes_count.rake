namespace :member do
    desc "Update votes counter cache for each member"
    task update_votes_counter: :environment do
        Member.all.each do |m|
            m.update_attribute :history_votes_count, m.history_votes.length
        end
    end    
end