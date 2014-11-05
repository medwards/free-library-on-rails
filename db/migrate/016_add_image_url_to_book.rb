class AddImageUrlToBook < ActiveRecord::Migration
  def change
    add_column :items, :cover_url, :string
  end
end
