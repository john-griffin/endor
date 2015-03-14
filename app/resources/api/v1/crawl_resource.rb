require 'jsonapi/resource'

module Api
  module V1
    class CrawlResource < JSONAPI::Resource
      attributes :name, :city, :user_id, :featured, :image_url, :stop_count

      has_many :stops

      def stop_count
        @model.stops.length
      end
    end
  end
end
