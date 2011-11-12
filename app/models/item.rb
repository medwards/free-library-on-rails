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

require 'taggable'

class Item < ActiveRecord::Base
	belongs_to :owner, :class_name => 'User'
	belongs_to :current_loan, :class_name => 'Loan'

	has_many :lendings, :class_name => 'Loan'

	has_many :requests, :class_name => 'Loan',
		:conditions => "status NOT IN ('#{I18n.t 'loans.status.lent'}', '#{I18n.t 'loans.status.returned'}', '#{I18n.t 'loans.status.rejected'}')"

	def self.tagging_class; ItemTagging; end
	include Taggable

	validates_presence_of :title, :created, :owner_id

	def loaned?
		!self.current_loan.nil?
	end

	def borrower
		if loaned?
			self.current_loan.borrower
		end
	end

	def returned!
		self.current_loan.status = I18n.t 'loans.status.returned'
		self.current_loan.save!

		self.current_loan = nil
		save!
	end

	def owned_by? user
		if user and user.is_a? User
			user = user.id
		end

		self.owner_id == user
	end

	def self.find_by_tag tag
		self.joins(:tags).where(:'tags.name' => tag)
	end

	# overridden by Item subclasses
	def has_cover_image?
		false
	end

	# return the newest x items
	def self.newest(x = 20)
		self.find(:all, :limit => x, :order => 'created DESC')
	end

	def self.paginated_search_title page, terms, extra_conditions = nil, extra_terms = []
		# turn terms into a list of SQL wildcards
		terms = terms.map { |t| "%#{t}%" }

		# set up condition strings
		cond = (['title LIKE ?'] * terms.length).join(' AND ')
		cond += ' ' + extra_conditions if extra_conditions

		# do the query
		self.where([cond, *(terms + extra_terms)]).order(:title).paginate(:page => page)
	end

	def self.paginated_search_author page, terms, extra_conditions = nil, extra_terms = []
		# turn terms into a list of SQL wildcards
		terms = terms.map { |t| "%#{t}%" }

		# set up condition strings
		cond = (['author_first LIKE ? OR author_last LIKE ?'] * terms.length).join(' AND ')
		cond += ' ' + extra_conditions if extra_conditions

		terms = terms.map { |x| [x] * 2 }.flatten

		# do the query
		self.where([cond, *(terms + extra_terms)]).order(:title).paginate(:page => page)
	end

	def self.paginated_search_description page, terms, extra_conditions = nil, extra_terms = []
		# turn terms into a list of SQL wildcards
		terms = terms.map { |t| "%#{t}%" }

		# set up condition strings
		cond = (['description LIKE ?'] * terms.length).join(' AND ')

		# do the query
		self.where([cond, *(terms + extra_terms)]).order(:title).paginate(:page => page)
	end
end
