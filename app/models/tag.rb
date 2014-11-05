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

class Tag < ActiveRecord::Base
	validates_uniqueness_of :name

	has_many :item_taggings
	has_many :items, :through => :item_taggings, :order => 'title', :source => :thing

	has_many :user_taggings
	has_many :users, :through => :user_taggings, :order => 'login', :source => :thing

	# a list of the tags in the database that are used at least once *for items*
	def self.only_used order = 'name'
		self.find :all, :conditions => [ 'item_taggings.tag_id = tags.id' ],
			:include => :item_taggings, :order => order
	end

	def self.search(q)
		# @todo order by match closeness
		where('name LIKE ?', "%#{q}%")
	end

	def to_s
		self.name
	end
end
