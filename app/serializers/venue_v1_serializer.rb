class VenueV1Serializer < ActiveModel::Serializer
  attributes :id, :name, :description, :photo_url, :location
end
