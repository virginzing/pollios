class ChangeTablenameUnSeePollsToNotInterestedPolls < ActiveRecord::Migration
  def change
    rename_table('un_see_polls', 'not_interested_polls')
  end
end
