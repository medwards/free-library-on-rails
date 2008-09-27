# to use this:
#
# 1. a XXXXTagging model needs to be defined, see ItemTagging or UserTagging
# 2. in the model you want to be taggable you need to define an class method named tagging_class:
#		def self.tagging_class; XXXXTagging; end
# 3. a xxxx_taggings table needs to be created, with a "tag_id" column and a "thing_id" column
# 4. 'include' this module in the model you want to be taggable

module Taggable
	def self.included(klass)
		klass.has_many :taggings,
			:class_name => klass.tagging_class.to_s,
			:foreign_key => :thing_id
	end

	# separate tags with commas and optional whitespace
	TAG_SEPARATOR = /\s*,\s*/

	# replace existing taggings with the tags in an Array or a
	# TAG_SEPARATOR separated string
	def tag_with tags
		return if tags.nil?

		if tags.is_a? String
			tags = tags.strip.split(TAG_SEPARATOR)
		end

		tags = tags.delete_if { |tag|
			AppConfig.TAG_BLACKLIST.include? tag
        }

		return if not tags or tags.empty?

		# delete this thing's existing taggings
		self.class.tagging_class.find_all_by_thing_id(self).each do |t|
			t.destroy
		end

		tags.uniq.each do |tag|
			if not self.tags.member? tag
				tagging = self.class.tagging_class.new
				tagging.tag = Tag.find_or_create_by_name tag
				tagging.thing = self

				self.taggings << tagging
			end
		end
	end

	# an Item's tags, as an Array of Strings
	def tags
		taggings.map { |t| t.to_s }
	end
end
