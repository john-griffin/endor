class CrawlV1Serializer < ActiveModel::Serializer
  attributes :id, :name, :city, :user_id, :featured, :image_url,
             :stop_count, :links

  def stop_count
    object.stops.length
  end

  def links
    {
      stops: api_v1_stops_path(crawl_id: object.id)
    }
  end
end
