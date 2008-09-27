class ItemTagging < ActiveRecord::Base
	belongs_to :thing, :class_name => 'Item'
	belongs_to :tag

	def to_s; tag.name; end
end
