if @outh_sentai.present?
	json.response_status "OK"
	json.member_detail do
		json.member_id @outh_sentai.id
		json.sentai_id @outh_sentai.sentai_id
		json.member_type @outh_sentai.member_type_text
		json.member_name @outh_sentai.sentai_name
		json.member_username @outh_sentai.username
		json.email @outh_sentai.email
		json.avatar @outh_sentai.avatar
		json.member_token @outh_sentai.token
	end
else
	json.response_status "ERROR"
	json.response_message "Unable update to your profile."
end