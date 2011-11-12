# Copyright 2009 Michael Edwards, Brendan Taylor
# This file is part of free-library-on-rails.
#
# free-library-on-rails is free software: you can redistribute it
# and/or modify it under the terms of the GNU Affero General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.

# free-library-on-rails is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License along with free-library-on-rails.
# If not, see <http://www.gnu.org/licenses/>.

# to make a model taggable:
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

		klass.has_many :tags, :through => :taggings
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

		tags = tags.delete_if do |tag|
			tag.empty? or AppConfig.TAG_BLACKLIST.include?(tag)
		end

		return if not tags or tags.empty?

		# delete this thing's existing taggings
		self.class.tagging_class.destroy_all(:thing_id => self)

		tags.uniq.each do |tag|
			self.add_tag tag
		end
	end

	# add a single String to this thing's tags
	def add_tag tag
		if not self.tags.member? tag
			tagging = self.class.tagging_class.new
			tagging.tag = Tag.find_or_create_by_name tag
			tagging.thing = self

			self.taggings << tagging
		end
	end
end
