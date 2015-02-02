class Crawl < ActiveRecord::Base
  has_many :stops
  belongs_to :user
end
