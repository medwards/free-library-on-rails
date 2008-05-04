class Item < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  belongs_to :held_by, :class_name => 'User',
    :foreign_key => "held_by"

  has_many :taggings, :class_name => 'ItemTagging'

  validates_presence_of :title, :created, :held_by, :owner_id

  # maybe single table inheritance is the best way to do this,
  # but we can worry about that later
  self.inheritance_column = :type

  def tag_with tags
    tags.each do |tag|
      tagging = ItemTagging.new
      tagging.tag = Tag.find_or_create_by_name tag
      tagging.item = self

      self.taggings << tagging
    end
  end

  def self.find_by_tag tag
    self.find_by_sql [
  'SELECT *
    FROM items i, item_taggings t, tags tag
    WHERE
    tag.name = ? AND t.tag_id = tag.id AND i.id = t.item_id', tag ]
  end

  def tag_counts
    counts = {}

    Tag.find_by_sql([
  'SELECT tag.name, COUNT(*) as count
    FROM item_taggings t, tags tag
    WHERE
    t.item_id = ? AND t.tag_id = tag.id
    GROUP BY tag.name', self.id ]).each do |t|
      counts[t.name] = t.count.to_i
    end

    counts
  end
end
