class Api::V1::StopsController < ApplicationController
  def index
    @stops = Stop.all

    if params[:crawl_id]
      @stops = @stops.where(crawl_id: params[:crawl_id])
    end

    render json: @stops, each_serializer: StopV1Serializer
  end
end
