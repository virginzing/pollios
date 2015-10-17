module Pollios::V1::Member
	class CampaignOwnerDetailEntity < Grape::Entity

		expose :id, as: :member_id
		expose :member_type_text, as: :type
		expose :fullname, as: :name
		expose :description do |object|
			object.description.to_s
		end
		expose :avatar do |object|
			object.avatar.present? ? resize_avatar(object.avatar.url) : ""
		end
		expose :key_color do |object|
			object.key_color.to_s
		end
		
		def resize_avatar(avatar_url)
    	avatar_url.split("upload").insert(1, "upload/c_fill,h_180,w_180," + Cloudinary::QualityImage::SIZE).sum
  	end

	end
end