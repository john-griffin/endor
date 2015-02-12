module Api
  module V1
    class StopsController < ApplicationController
      before_action :authenticate_user!, only: [:create, :update, :destroy]
      before_action :set_stop, only: [:update, :destroy, :show]
      before_action :set_venue, only: [:update, :create]
      before_action :check_owner, only: [:update, :destroy]

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
        crawl = Crawl.find(stop_params[:crawl_id])
        current_user?(crawl.user.id)
        @stop = Stop.new(stop_params.merge(venue: @venue))

        if @stop.save
          render json: @stop, status: :created, root: :stop,
                 serializer: StopV1Serializer, location: [:api, :v1, @stop]
        else
          render json: { errors: @stop.errors }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        head 422, 'content_type' => 'text/plain'
      end

      def update
        if @stop.update(stop_params.merge(venue: @venue))
          render json: @stop, status: :ok, root: :stop,
                 serializer: StopV1Serializer, location: [:api, :v1, @stop]
        else
          render json: { errors: @stop.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @stop.destroy

        head :no_content
      end

      def show
        render json: @stop, status: :ok, root: :stop,
               serializer: StopV1Serializer, location: [:api, :v1, @stop]
      end

      private

      def check_owner
        current_user?(@stop.user.id)
      end

      def current_user?(user_id)
        head :unauthorized if current_user.id != user_id
      end

      def set_venue
        @venue = Venue.find_or_initialize_by(venue_id_params) do |v|
          v.assign_attributes(venue_params)
        end
      end

      def set_stop
        @stop = Stop.includes(:venue, crawl: [:user]).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head 404, 'content_type' => 'text/plain'
      end

      def stop_params
        reqest_params.slice(:crawl_id, :name, :row_order_position, :photo_id,
                            :photo_prefix, :photo_suffix)
      end

      def venue_id_params
        venue_params.slice(:foursquare_id)
      end

      def venue_params
        vp = reqest_params.slice(
          :description, :venue_name, :foursquare_id, :location, :point)
        vp[:name] = vp.delete(:venue_name)
        vp
      end

      def reqest_params
        params.require(:stop).permit(:crawl_id, :name, :row_order_position,
                                     :description, :venue_name, :photo_id,
                                     :photo_prefix, :photo_suffix,
                                     :foursquare_id, point: [], location: [])
      end
    end
  end
end
