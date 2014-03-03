if @outh_sentai.present?
	json.response_status "OK"
	json.member_detail do
		json.member_id @outh_sentai.id
		json.sentai_id @outh_sentai.sentai_id
		json.type @outh_sentai.member_type_text
		json.name @outh_sentai.sentai_name
		json.username @outh_sentai.username
		json.email @outh_sentai.email
		json.birthday @outh_sentai.birthday.present? ? @outh_sentai.birthday : ""
		json.gender @outh_sentai.check_gender
		json.province @outh_sentai.get_province
		json.avatar @outh_sentai.avatar
		json.token @outh_sentai.token
	end
else
	json.response_status "ERROR"
	json.response_message "Unable update to your profile."
end