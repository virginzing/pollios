module SymbolHash

  TYPE = {
    :poll => 'Poll',
    :poll_series => 'PollSeries',
    :friend => 'Friend',
    :group => 'Group',
    :member => 'Member',
    :comment => 'Comment',
    :requset_group => 'RequestGroup',
    :save_poll_later => 'SavePollLater'
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
    :comment => 'Comment',
    :mention => 'Mention',
    :also_comment => 'AlsoComment',
    :report => 'Report'
  }

  AUTHORITY = {
    :public => 'Public',
    :friend_following => 'Friends & Following',
    :group => 'Group',
    :private => 'Private'
  }

end