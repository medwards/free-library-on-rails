class Item < ActiveRecord::Base
	belongs_to :owner, :class_name => 'User'
	belongs_to :current_loan, :class_name => 'Loan'

	has_many :lendings, :class_name => 'Loan'

	has_many :requests, :class_name => 'Loan',
		:conditions => "status NOT IN ('lent', 'returned', 'rejected')"

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
		self.current_loan.status = 'returned'
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
		tag = Tag.find_by_name(tag)

		tag ? tag.items : []
	end
end
