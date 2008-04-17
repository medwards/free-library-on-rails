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
