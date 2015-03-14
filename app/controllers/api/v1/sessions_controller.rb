module Api
  module V1
    class SessionsController < Devise::SessionsController
      def create
        self.resource = warden.authenticate(auth_options)
        if resource
          sign_in(resource_name, resource)
          render json: {
            token: resource.authentication_token,
            email: resource.email, id: resource.id
          }, status: 201
        else
          head :unauthorized, 'content_type' => 'text/plain'
        end
      end
    end
  end
end
