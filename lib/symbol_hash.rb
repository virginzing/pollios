module SymbolHash

  TYPE = {
    :poll => 'Poll',
    :friend => 'Friend',
    :group => 'Group',
    :member => 'Member',
    :comment => 'Comment'
  }

  ACTION = {
    :vote => 'Vote',
    :create => 'Create',
    :share => 'Share',
    :become_friend => 'BecomeFriend',
    :follow => 'Follow',
    :join => 'Join',
    :invite => 'Invite',
    :request => 'Request',
    :change_name => 'ChangeName',
    :change_avatar => 'ChangeAvatar',
    :change_cover => 'ChangeCover',
    :comment => 'Comment'
  }

  AUTHORITY = {
    :public => 'Public',
    :friend_following => 'Friends & Following',
    :group => 'Group',
    :private => 'Private'
  }
  
end