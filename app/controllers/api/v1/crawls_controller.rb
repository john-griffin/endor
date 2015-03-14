require 'jsonapi/resource_serializer'

module Api
  module V1
    class CrawlsController < ApplicationController
      before_action :authenticate_user!, only: [:create, :update, :destroy]
      before_action :set_crawl,          only: [:update, :show, :destroy]
      before_action :check_owner,        only: [:update, :destroy]

      def show
        serializer = JSONAPI::ResourceSerializer.new(CrawlResource)
        render json: serializer.serialize_to_hash(CrawlResource.new(@crawl))
      end

      def create
        @crawl = current_user.crawls.new(crawl_params)
        if @crawl.save
          serializer = JSONAPI::ResourceSerializer.new(CrawlResource)
          render json: serializer.serialize_to_hash(CrawlResource.new(@crawl)), status: :created
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
        user_crawls = current_user ? current_user.crawls.includes(:stops) : []
        featured_crawls = Crawl.where(featured: true).includes(:stops)
        @crawls = user_crawls | featured_crawls
        serializer = JSONAPI::ResourceSerializer.new(CrawlResource)
        render json: serializer.serialize_to_hash(
          @crawls.map{|c| CrawlResource.new(c)}
        )
      end

      def destroy
        @crawl.destroy

        head :no_content
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
        params.require(:crawl).permit(:name, :city, :image_url)
      end
    end
  end
end
