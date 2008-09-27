class UserTagging < ActiveRecord::Base
	belongs_to :thing, :class => 'User'
	belongs_to :tag

	def to_s; tag.name; end
end
