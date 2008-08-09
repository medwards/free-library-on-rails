# integer latitudes and longitudes don't give very good precision
class GeoPrecision < ActiveRecord::Migration
  def self.up
    change_column :users, :latitude,  :decimal, :scale => 3, :precision => 6, :null => false
    change_column :users, :longitude, :decimal, :scale => 3, :precision => 6, :null => false
  end

  def self.down
    change_column :users, :latitude,  :integer, :null => false
    change_column :users, :longitude, :integer, :null => false
  end
end
