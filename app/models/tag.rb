class Tag < ActiveRecord::Base
	validates_uniqueness_of :name

	has_many :item_taggings
	has_many :items, :through => :item_taggings, :order => 'title'

	# a list of the tags in the database that are used at least once
	def self.only_used order = 'name'
		self.find :all, :conditions => [ 'item_taggings.tag_id = tags.id' ],
			:include => :item_taggings, :order => order
	end
end
