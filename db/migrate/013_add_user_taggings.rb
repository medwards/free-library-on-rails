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
