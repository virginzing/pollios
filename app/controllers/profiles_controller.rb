class ProfilesController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :authenticate_with_token!, only: [:load_form, :update_personal_detail]

  # def load_form
  #   @form = [{
  #     "title" => "Basic Info",
  #     "fields" => [
  #       {
  #         "type" => "date",
  #         "key" => "birthday",
  #         "title" => "Birthday",
  #         "placeholder" => "What's you birthday?"
  #       },
  #       {
  #         "type" => "single-choice",
  #         "key" => "gender",
  #         "title" => "Gender",
  #         "placeholder" => "Please select your gender",
  #         "choices" => Member.gender.values.collect{|e| {"title" => e.text, "value" => e.value }}
  #       },
  #       {
  #         "type" => "single-choice",
  #         "key" => "province",
  #         "title" => "Province",
  #         "placeholder" => "Please select your province",
  #         "choices" => Member.province.values.collect{|e| {"title" => e.text, "value" => e.value }}
  #       },
  #       {
  #         "type" => "multi-choices",
  #         "key" => "interests",
  #         "title" => "Interests",
  #         "placeholder" => "Not select",
  #         "choices" => Member.interests.values.collect{|e| {"title" => e.text, "value" => e.value }}
  #       },
  #       {
  #         "type" => "single-choice",
  #         "key" => "salary",
  #         "title" => "Salary",
  #         "placeholder" => "Select salary range",
  #         "choices" => Member.salary.values.collect{|e| {"title" => e.text, "value" => e.value }}
  #       }
  #     ]
  #   }]

  #   @member_profiles = {
  #     "birthday" => @current_member.get_birthday,
  #     "gender" => @current_member.get_gender,
  #     "province" => @current_member.get_province,
  #     "interests" => @current_member.get_interests,
  #     "salary" => @current_member.get_salary
  #   }
  # end

  def load_form
    @form = [{
      "title" => "Basic Info",
      "fields" => [
        {
          "type" => "date",
          "key" => "birthday",
          "title" => "Birthday",
          "placeholder" => "What's you birthday?"
        },
        {
          "type" => "single-choice",
          "key" => "gender",
          "title" => "Gender",
          "placeholder" => "Please select your gender",
          "choices" => Member.gender.values.collect{|e| {"title" => e.text, "value" => e.value }}
        }
      ]
    }]

    @member_profiles = {
      "birthday" => @current_member.get_birthday,
      "gender" => @current_member.get_gender
    }
  end

  def update_personal_detail
    respond_to do |format|
      if @current_member.update(personal_detail_params)
        @current_member.update!(update_personal: true)
        format.json { render json: { "response_status" => "OK" }, status: :created }
      else
        format.json { render json: { "response_status" => @current_member.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end



  private

  def personal_detail_params
    params.permit(:birthday, :province, :gender, :salary, :interests => [])
  end

end
