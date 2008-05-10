class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table 'regions', :force => true do |t|
      t.string :name, :null => false
      t.string :subdomain, :null => false
    end

    Region.create :name => 'Edmonton', :subdomain => 'edmonton'
  end

  def self.down
    drop_table 'regions'
  end
end
