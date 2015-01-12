class StopV1Serializer < ActiveModel::Serializer
  attributes :id, :name

  has_one :venue, serializer: VenueV1Serializer
end
