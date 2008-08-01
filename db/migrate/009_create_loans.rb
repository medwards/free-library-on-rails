class CreateLoans < ActiveRecord::Migration
  def self.up
    create_table 'loans', :force => true do |t|
      t.integer :item_id, :null => false
      t.integer :borrower_id, :null => false
      t.string :status, :null => false
      t.datetime :return_date
    end

    remove_column :items, :held_by
    remove_column :items, :date_back

    add_column :items, :current_loan_id, :integer

    remove_column :items, :current_loan
  end

  def self.down
    drop_table 'loans'

    # this column was NOT NULL, but restoring that requires some
    # logic that I don't think we need
    add_column :items, :held_by, :integer
    add_column :items, :date_back, :datetime

    remove_column :items, :current_loan_id
  end
end
