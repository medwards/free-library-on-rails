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

class CreateItems < ActiveRecord::Migration
  def self.up
    create_table "items", :force => true do |t|
      t.string :type, :null => false
      t.string :title, :null => false
      t.text :description
      t.datetime :created, :null => false
      t.datetime :date_back
      t.integer :held_by, :null => false
      t.integer :owner_id, :null => false
    end
  end

  def self.down
    drop_table "items"
  end
end
