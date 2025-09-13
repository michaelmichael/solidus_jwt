# frozen_string_literal: true

module SolidusJwt
  module Spree
    module Api
      module BaseControllerDecorator
        def self.prepended(base)
          base.rescue_from JWT::DecodeError do
            render "spree/api/errors/invalid_api_key", status: :unauthorized
          end

          # Add before_action to handle JWT authentication
          base.prepend_before_action :authenticate_with_jwt
        end

        private

        def authenticate_with_jwt
          return if @current_api_user # Already authenticated

          jwt = json_web_token
          if jwt.present?
            user = ::Spree.user_class.for_jwt(jwt['sub'] || jwt['id'])
            if user
              # Instead of setting @current_api_user directly, let's make the system
              # use the user's actual spree_api_key for authentication
              @jwt_user_api_key = user.spree_api_key
            end
          end
        end

        def api_key
          # If we have a JWT user's API key, return that instead
          return @jwt_user_api_key if @jwt_user_api_key

          super
        end

        def json_web_token
          return @json_web_token if defined?(@json_web_token)

          begin
            @json_web_token = SolidusJwt.decode(api_key).first
          rescue JWT::DecodeError
            # Allow spree to try and authenticate if we still allow it. Otherwise
            # raise an error
            if SolidusJwt::Config.allow_spree_api_key
              @json_web_token = nil
            else
              raise
            end
          end

          @json_web_token
        end

        if SolidusSupport.api_available?
          ::Spree::Api::BaseController.prepend self
        end
      end
    end
  end
end
