module Api
  module V1
    class CrawlsController < ApplicationController
      before_action :authenticate_user!, only: [:create]

      def show
        @crawl = Crawl.find(params[:id])
        render json: @crawl, serializer: CrawlV1Serializer, root: :crawl
      rescue ActiveRecord::RecordNotFound
        head 404, 'content_type' => 'text/plain'
      end

      def create
        @crawl = current_user.crawls.new(crawl_params)
        if @crawl.save
          render json: @crawl, status: :created, root: :crawl,
                 serializer: CrawlV1Serializer, location: [:api, :v1, @crawl]
        else
          render json: { errors: @crawl.errors }, status: :unprocessable_entity
        end
      end

      private

      def crawl_params
        params.require(:crawl).permit(:name, :city)
      end
    end
  end
end
