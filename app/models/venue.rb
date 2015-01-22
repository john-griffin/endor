class Venue < ActiveRecord::Base
  has_many :stops

  validates :foursquare_id, presence: true
end
