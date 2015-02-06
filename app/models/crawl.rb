class Crawl < ActiveRecord::Base
  has_many :stops
  belongs_to :user

  validates :name, presence: true
  validates :city, presence: true
end
