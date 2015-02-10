class Crawl < ActiveRecord::Base
  has_many :stops, dependent: :destroy
  belongs_to :user

  validates :name, presence: true
  validates :city, presence: true
end
