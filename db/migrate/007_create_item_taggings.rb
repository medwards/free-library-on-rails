class CreateItemTaggings < ActiveRecord::Migration
  def self.up
    create_table 'item_taggings' do |t|
      t.integer 'item_id'
      t.integer 'user_id'
      t.integer 'tag_id'
    end

    create_table 'tags' do |t|
      t.string 'name'
    end
  end

  def self.down
    drop_table 'item_taggings'
    drop_table 'tags'
  end
end
