module Api
  module V1
    class SessionsController < Devise::SessionsController
      def create
        self.resource = warden.authenticate(auth_options)
        if self.resource
          sign_in(resource_name, resource)
          render json: resource, status: 201,
                 serializer: ResourceV1Serializer, root: false
        else
          head :unauthorized, 'content_type' => 'text/plain'
        end
      end
    end
  end
end
