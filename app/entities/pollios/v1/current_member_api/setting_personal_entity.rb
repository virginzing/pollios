module Pollios::V1::CurrentMemberAPI
  class SettingPersonalEntity < Pollios::V1::BaseEntity

    expose :form
    expose :data do
      expose :birthday
      expose :gender
    end

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

    def member
      object
    end

    def gender
      member.gender.present? ? member.gender.value : nil
    end

  end
end