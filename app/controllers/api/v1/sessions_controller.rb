class Api::V1::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    render json: self.resource, status: 201,
           serializer: ResourceV1Serializer, root: false
  end
end
