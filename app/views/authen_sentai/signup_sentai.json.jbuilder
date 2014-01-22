if @outh_sentai.present? && @outh_sentai["response_status"] != "ERROR"
	json.response_status "OK"
	json.member_detail do
		json.member_id @member.id
		json.sentai_id @outh_sentai["sentai_id"]
		json.member_name @outh_sentai["fullname"]
		json.member_username @outh_sentai["username"]
		json.email @outh_sentai["email"]
		json.avatar @outh_sentai["avatar_thumbnail"]
		json.member_token @member.token
	end
else
	json.response_status @outh_sentai["response_status"]
	json.response_message @outh_sentai["response_message"]
end