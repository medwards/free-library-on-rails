class Item < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  belongs_to :held_by, :class_name => 'User',
    :foreign_key => "held_by"

  # maybe single table inheritance is the best way to do this,
  # but we can worry about that later
  self.inheritance_column = :something_unlikely
end
