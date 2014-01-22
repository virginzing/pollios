if @outh_sentai.present?
	json.response_status "OK"
	json.member_detail do
		json.member_id @outh_sentai.id
		json.sentai_id @outh_sentai.sentai_id
		json.member_name @outh_sentai.sentai_name
		json.member_username @outh_sentai.username
		json.email @outh_sentai.email
		json.avatar @outh_sentai.avatar
		json.member_token @outh_sentai.token
		if @outh_sentai.subscription
			json.subscription_detail do
				json.subscription @outh_sentai.subscription
				json.subscribe_last @outh_sentai.subscribe_last
				json.subscribe_expire @outh_sentai.subscribe_expire.strftime("%Y-%m-%d %H:%M:%S")
			end
		end
	end
else
	json.response_status "ERROR"
	json.response_message "Unable update to your profile."
end