class ItemTagging < ActiveRecord::Base
  belongs_to :item
  belongs_to :tag

  def to_s
    tag.name
  end
end
