if @group_active || @group_inactive
  json.group_active @group_active, partial: 'group/detail', as: :group
  json.group_inactive @group_inactive, partial: 'group/detail', as: :group
end