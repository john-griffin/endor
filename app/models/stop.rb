class Stop < ActiveRecord::Base
  include RankedModel
  ranks :row_order, with_same: :crawl_id

  belongs_to :crawl
  belongs_to :venue
end
