module Pollios::V1::Shared
	class MemberDetailEntity < Grape::Entity

		expose :id, as: :member_id
		expose :member_type_text, as: :type

	end
end