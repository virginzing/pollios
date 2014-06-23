module SymbolHash

  TYPE = {
    :poll => 'Poll',
    :friend => 'Friend',
    :group => 'Group'
  }

  ACTION = {
    :vote => 'Vote',
    :create => 'Create',
    :share => 'Share',
    :become_friend => 'BecomeFriend',
    :follow => 'Follow',
    :join => 'Join',
    :invite => 'Invite',
    :request => 'Request'
  }

  AUTHORITY = {
    :public => 'Public',
    :friend_following => 'Friends & Following',
    :group => 'Group',
    :private => 'Private'
  }
  
end