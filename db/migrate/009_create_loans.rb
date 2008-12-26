# Copyright 2009 Michael Edwards, Brendan Taylor
# This file is part of free-library-on-rails.
# 
# free-library-on-rails is free software: you can redistribute it
# and/or modify it under the terms of the GNU Affero General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.

# free-library-on-rails is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public
# License along with free-library-on-rails.
# If not, see <http://www.gnu.org/licenses/>.

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
