module Pollios::V1::CurrentMemberAPI
  class SettingPersonalEntity < Pollios::V1::BaseEntity

    expose :form
    expose :birthday
    expose :gender

    def form
      [
        {
          title: 'Basic Info',
          fields: [
            {
              type: 'date',
              key: 'birthday',
              title: 'Birthday',
              placeholder: "What's you birthday?"
            },
            {
              type: 'single-choice',
              key: 'gender',
              title: 'Gender',
              placeholder: 'Please select your gender',
              choices: Member.gender.values.collect { |e| { title: e.text, value: e.value } }
            }
          ]
        }
      ]
    end

  end
end