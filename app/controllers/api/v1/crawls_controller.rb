class Api::V1::CrawlsController < ApplicationController
  def show
    @crawl = Crawl.find(params[:id])
    render json: @crawl, serializer: CrawlV1Serializer, root: :crawl
  end
end
