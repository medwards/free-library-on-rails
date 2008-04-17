class CreateItems < ActiveRecord::Migration
  def self.up
    create_table "items", :force => true do |t|
      t.string :type, :null => false
      t.string :title, :null => false
      t.text :description
      t.datetime :created, :null => false
      t.datetime :date_back, :null => false
      t.integer :held_by, :null => false
      t.integer :owner_id, :null => false
    end
  end

  def self.down
    drop_table "items"
  end
end
