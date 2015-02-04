class ResourceV1Serializer < ActiveModel::Serializer
  attributes :token, :email, :id

  def token
    object.authentication_token
  end
end
