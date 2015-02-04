class Stop < ActiveRecord::Base
  include RankedModel
  ranks :row_order, with_same: :crawl_id

  belongs_to :crawl
  belongs_to :venue
  has_one :user, through: :crawl

  validates_associated :venue
  validates :crawl, presence: true
  validates :venue, presence: true
end
