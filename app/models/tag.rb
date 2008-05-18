class Tag < ActiveRecord::Base
  validates_uniqueness_of :name

  has_many :item_taggings
  has_many :items, :through => :item_taggings
end
