class AddLibrarianToUsers < ActiveRecord::Migration
  def change
    add_column :users, :librarian_since, :datetime
  end
end
