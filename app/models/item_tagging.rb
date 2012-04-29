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

class ItemTagging < ActiveRecord::Base
	belongs_to :thing, :class_name => 'Item', :foreign_key => 'thing_id'
	belongs_to :tag

	def to_s; tag.name; end

	def self.counts
		ItemTagging.
			joins(:tag).
			count( :group => 'name', :order => 'COUNT(*) DESC, name ASC')
	end
end
