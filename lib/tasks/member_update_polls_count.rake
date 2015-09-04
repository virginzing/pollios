namespace :member do
    desc "Update polls counter cache for each member"
    task update_polls_counter: :environment do
        Member.all.each do |m|
            m.update_attribute :polls_count, m.polls.length
        end
    end    
end