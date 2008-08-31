class Region < ActiveRecord::Base
	has_many :users
	has_many :items, :through => :users, :source => :owned
end
