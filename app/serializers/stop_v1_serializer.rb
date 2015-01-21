class StopV1Serializer < ActiveModel::Serializer
  attributes :id, :row_order, :name, :venue_name, :description, :photo_url, :location, :foursquare_id

  def venue_name
    venue.name
  end

  def description
    venue.description
  end

  def photo_url
    venue.photo_url
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
