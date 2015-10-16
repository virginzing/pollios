module Pollios::V1::Shared
	class PollDetailEntity < Grape::Entity
		expose :id
		expose :title
	end
end