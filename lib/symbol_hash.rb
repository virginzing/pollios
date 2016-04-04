module SymbolHash
  TYPE = {
    :poll => 'Poll',
    :poll_series => 'PollSeries',
    :friend => 'Friend',
    :group => 'Group',
    :member => 'Member',
    :comment => 'Comment',
    :request_group => 'RequestGroup',
    :save_poll_later => 'SavePollLater',
    :reward => 'Reward',
    :system_message => 'SystemMessage',
    :subscription => 'Subscription'
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
    :report => 'Report',
    :poke => 'Poke',
    :request_friend => 'RequestFriend',
    :receive_reward => 'ReceiveReward',
    :promote_admin => 'PromoteAdmin',
    :subscription_nearly_expire => 'SubscriptionNearlyExpire',
    :subscription_expire => 'SubscriptionExpire'
  }

  AUTHORITY = {
    :public => 'Public',
    :friend_following => 'Friends & Following',
    :group => 'Group',
    :private => 'Private'
  }

  WORKER = {
    :add_follow => 'AddFollow',
    :approve_request_group => 'ApproveRequestGroup',
    :add_friend => 'AddFriend',
    :add_member_to_group => 'AddMemberToGroup',
    :add_poll_to_group => 'AddPollToGroup',
    :all_gift => 'AllGift',
    :nearly_expire_subsription => 'NearlyExpireSubscription',
    :comment_mention => 'CommentMention',
    :comment_poll => 'CommentPoll',
    :company_add_user_to_group => 'CompanyAddUserToGroup',
    :invite_friend_to_group => 'InviteFriendToGroup',
    :join_group => 'JoinGroup',
    :not_receive_random_reward_poll => 'NotReceiveRandomRewardPoll',
    :notify_expire_subscription => 'NotifyExpireSubscription',
    :one_gift => 'OneGift',
    :poke_invites_friend_to_group => 'PokeInvitedFriendToGroupWorker',
    :poke_poll => 'PokePoll',
    :poll => 'Poll',
    :promote_admin => 'PromoteAdmin',
    :questionnaire => 'Questionnaire',
    :receive_random_reward_poll => 'ReceiveRandomRewardPoll',
    :report_poll => 'ReportPoll',
    :request_group => 'RequestGroup',
    :reward => 'Reward',
    :all_message => 'Message',
    :save_poll => 'SavePoll',
    :sum_vote_poll => 'SumVotePoll',
    :vote_poll => 'VotePoll',
    friends_request: 'FriendsRequest',
    sum_voted: 'SumVoted',
    receive_reward: 'ReceiveReward',
    not_receive_reward: 'NotReceiveReward'
  }

end