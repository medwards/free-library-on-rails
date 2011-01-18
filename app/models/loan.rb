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

# the 'status' field holds a string that is one of:
#		- requested
#		- approved		<- this is not used at the moment, it goes straight to lent
#		- lent
#		- returned
#		- rejected
#
#		You can translate this strings in a new locale file
#		(such as 'es.yml') in config/locales/
class Loan < ActiveRecord::Base
	belongs_to :item
	belongs_to :borrower, :class_name => 'User'

	# this should be commented out for rails 2.0.2
	define_callbacks :after_lent, :after_rejected

	def owner
		self.item.owner
	end

	def approved?
		(I18n.t ['approved', 'lent', 'returned'], :scope => 'loans.status').member? self.status
	end

	def approved!
		self.status = I18n.t 'loans.status.approved'
		save!
	end

	def rejected?
		self.status == I18n.t('loans.status.rejected')
	end

	def rejected!
		self.status = I18n.t 'loans.status.rejected'
		save!
		callback :after_rejected
	end

	def lent!(return_date, memo = nil)
		self.return_date = return_date
		self.memo = memo
		self.status = I18n.t 'loans.status.lent'
		save!

		self.item.current_loan = self
		self.item.save!
		callback :after_lent
	end

	def returned!
		self.status = I18n.t 'loans.status.returned'
		save!

		self.item.current_loan = nil
		self.item.save!
	end

	# make a new loan request
	def self.create_request(user, item)
		self.create(:borrower => user, :item => item, :status => I18n.t('loans.status.requested'))
	end

	# does this user already have an outstanding loan for this item?
	def self.already_requested(user, item)
		self.exists? ["borrower_id = ? AND item_id = ?" \
			" AND status NOT IN ('#{I18n.t 'loans.status.returned'}', '#{I18n.t 'loans.status.rejected'}')", user, item]
	end
end
