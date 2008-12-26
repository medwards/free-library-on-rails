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

class AddUserLocation < ActiveRecord::Migration
  def self.up
	add_column :users, :address, :string
	add_column :users, :city, :string
	add_column :users, :postalcode, :string, :limit => 6
	add_column :users, :latitude, :integer
	add_column :users, :longitude, :integer
	# ok so not user location data. I forgot ok?
	add_column :users, :cellphone, :string, :limit => 10
	add_column :users, :cellphone_provider, :string
	add_column :users, :region_id, :integer, :default => 1

	User.update_all ['region_id = ?', 1]
	User.update_all ['postalcode = ?', 'T5K1M1']

  change_column :users, :postalcode, :string, :null => false

  change_column :users, :longitude, :integer, :null => false
  change_column :users, :latitude, :integer, :null => false
  end

  def self.down
	remove_column :users, :address
	remove_column :users, :city
	remove_column :users, :postalcode
	remove_column :users, :latitude
	remove_column :users, :longitude
	remove_column :users, :cellphone
	remove_column :users, :cellphone_provider
	remove_column :users, :region_id
  end
end
