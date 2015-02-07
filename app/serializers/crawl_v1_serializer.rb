class CrawlV1Serializer < ActiveModel::Serializer
  attributes :id, :name, :city, :user_id, :featured, :links

  def links
    {
      stops: api_v1_stops_path(crawl_id: object.id)
    }
  end
end
