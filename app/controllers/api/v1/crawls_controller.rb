class Api::V1::CrawlsController < ApplicationController
  def show
    @crawl = Crawl.find(params[:id])
    render json: @crawl, serializer: CrawlV1Serializer, root: :crawl
  rescue ActiveRecord::RecordNotFound
    head 404, "content_type" => 'text/plain'
  end
end
