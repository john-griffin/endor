class Stop < ActiveRecord::Base
  belongs_to :crawl
  belongs_to :venue
end
