class Api::V1::StopsController < ApplicationController
  def index
    @stops = Stop.all.includes(:venue)

    if params[:crawl_id]
      @stops = @stops.where(crawl_id: params[:crawl_id])
    end

    render json: @stops, each_serializer: StopV1Serializer
  end

  def create
    venue = Venue.new(venue_params)
    @stop = Stop.new(stop_params.merge(venue: venue))

    if @stop.save
      render json: @stop, status: :created, root: :stop,
             serializer: StopV1Serializer, location: [:api, :v1, @stop]
    else
      render json: { errors: @stop.errors }, status: :unprocessable_entity
    end
  end

  private

  def stop_params
    reqest_params.slice(:crawl_id, :name)
  end

  def venue_params
    vp = reqest_params.slice(
      :description, :venue_name, :photo_url, :foursquare_id, :location)
    vp[:name] = vp.delete(:venue_name)
    vp
  end

  def reqest_params
    params.require(:stop).permit(:crawl_id, :name,
      :description, :venue_name, :photo_url, :foursquare_id, location: [])
  end
end
