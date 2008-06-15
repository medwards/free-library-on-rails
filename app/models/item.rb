class Item < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  belongs_to :current_loan, :class_name => 'Loan'

  has_many :lendings, :class_name => 'Loan'

  has_many :requests, :class_name => 'Loan',
    :conditions => "status NOT IN ('returned', 'rejected')"

  has_many :taggings, :class_name => 'ItemTagging'

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

  # replace existing taggings with the tags in an Array or a
  # space-separated string
  def tag_with tags
    if tags.is_a? String
      tags = tags.split(' ')
    end

    return if not tags or tags.empty?

    ItemTagging.find_all_by_item_id(self).each do |t|
      t.destroy
    end

    tags.each do |tag|
      tagging = ItemTagging.new
      tagging.tag = Tag.find_or_create_by_name tag
      tagging.item = self

      self.taggings << tagging
    end
  end

  # an Item's tags, as an Array of Strings
  def tags
    taggings.map { |t| t.to_s }
  end

  def self.find_by_tag tag
    Tag.find_by_name(tag).items
  end
end
