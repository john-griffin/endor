module Api
  module V1
    class StopsController < ApplicationController
      def index
        if params[:crawl_id]
          @stops = Stop.where(crawl_id: params[:crawl_id])
                   .rank(:row_order)
                   .includes(:venue)
          render json: @stops, each_serializer: StopV1Serializer
        else
          head :unprocessable_entity, 'content_type' => 'text/plain'
        end
      end

      def create
        venue = Venue.find_or_initialize_by(venue_id_params) do |v|
          v.assign_attributes(venue_params)
        end
        @stop = Stop.new(stop_params.merge(venue: venue))

        if @stop.save
          render json: @stop, status: :created, root: :stop,
                 serializer: StopV1Serializer, location: [:api, :v1, @stop]
        else
          render json: { errors: @stop.errors }, status: :unprocessable_entity
        end
      end

      def update
        @stop = Stop.find(params[:id])

        if @stop.update(stop_params)
          render json: @stop, status: :ok, root: :stop,
                 serializer: StopV1Serializer, location: [:api, :v1, @stop]
        else
          render json: { errors: @stop.errors }, status: :unprocessable_entity
        end
      end

      private

      def stop_params
        reqest_params.slice(:crawl_id, :name, :row_order_position)
      end

      def venue_id_params
        venue_params.slice(:foursquare_id)
      end

      def venue_params
        vp = reqest_params.slice(
          :description, :venue_name, :photo_url, :foursquare_id, :location)
        vp[:name] = vp.delete(:venue_name)
        vp
      end

      def reqest_params
        params.require(:stop).permit(:crawl_id, :name, :row_order_position,
                                     :description, :venue_name, :photo_url,
                                     :foursquare_id, location: [])
      end
    end
  end
end
