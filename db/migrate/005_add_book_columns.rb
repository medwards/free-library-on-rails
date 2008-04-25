class AddBookColumns < ActiveRecord::Migration
  def self.up
    add_column :items, :isbn, :string
    add_column :items, :author_first, :string
    add_column :items, :author_last, :string
  end

  def self.down
    remove_column :items, :isbn
    remove_column :items, :author_first
    remove_column :items, :author_last
  end
end
