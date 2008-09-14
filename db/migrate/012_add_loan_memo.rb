class AddLoanMemo < ActiveRecord::Migration
  def self.up
	add_column :loans, :memo, :string
  end

  def self.down
	remove_column :loans, :memo
  end
end
