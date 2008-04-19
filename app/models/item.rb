class Item < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  belongs_to :held_by, :class_name => 'User',
    :foreign_key => "held_by"

  validates_presence_of :title, :created, :held_by, :owner_id

  # maybe single table inheritance is the best way to do this,
  # but we can worry about that later
  self.inheritance_column = :type
end
