module Api
  module V1
    class StopResource < JSONAPI::Resource
      attributes :crawl_id, :row_order, :name, :venue_name, :description,
                 :photo_id, :photo_prefix, :photo_suffix, :location, :point,
                 :foursquare_id

      def point
        venue.point
      end

      def venue_name
        venue.name
      end

      def description
        venue.description
      end

      def location
        venue.location
      end

      def foursquare_id
        venue.foursquare_id
      end

      def venue
        @model.venue
      end
    end
  end
end