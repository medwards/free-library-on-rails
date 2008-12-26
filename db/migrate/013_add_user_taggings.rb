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

class AddUserTaggings < ActiveRecord::Migration
  def self.up
	rename_column :item_taggings, :item_id, :thing_id

    create_table 'user_taggings' do |t|
      t.integer 'thing_id', :null => false
      t.integer 'tag_id', :null => false
    end
  end

  def self.down
	rename_column :item_taggings, :thing_id, :item_id

    drop_table 'user_taggings'
  end
end
