class StopV1Serializer < ActiveModel::Serializer
  attributes :id, :crawl_id, :row_order, :name, :venue_name, :description,
             :photo_id, :photo_prefix, :photo_suffix, :location, :foursquare_id

  def venue_name
    venue.name
  end

  def description
    venue.description
  end

  def location
    venue.location
  end

  def foursquare_id
    venue.foursquare_id
  end

  def venue
    object.venue
  end
end
