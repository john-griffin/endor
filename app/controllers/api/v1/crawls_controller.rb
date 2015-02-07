module Api
  module V1
    class CrawlsController < ApplicationController
      before_action :authenticate_user!, only: [:create, :update]
      before_action :set_crawl, only: [:update, :show]
      before_action :check_owner, only: [:update]

      def show
        render json: @crawl, serializer: CrawlV1Serializer, root: :crawl
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

      def update
        if @crawl.update(crawl_params)
          render json: {}, status: :ok
        else
          render json: { errors: @crawl.errors }, status: :unprocessable_entity
        end
      end

      def index
        # featured crawls and user owned crawls if logged in
        user_crawls = current_user ? current_user.crawls : []
        featured_crawls = Crawl.where(featured: true)
        @crawls = user_crawls | featured_crawls
        render json: @crawls, each_serializer: CrawlV1Serializer
      end

      private

      def check_owner
        current_user?(@crawl.user_id)
      end

      def current_user?(user_id)
        head :unauthorized if current_user.id != user_id
      end

      def set_crawl
        @crawl = Crawl.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head 404, 'content_type' => 'text/plain'
      end

      def crawl_params
        params.require(:crawl).permit(:name, :city)
      end
    end
  end
end
