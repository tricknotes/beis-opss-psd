module Users
  class ExchangeToken
    extend ActiveModel::Naming
    include Interactor

    def call
      unless user_signed_in?
        context.access_token = api_client.exchange_refresh_token_for_token(refresh_token)
      end
    rescue Keycloak::KeycloakException
      raise
    rescue StandardError => e
      Raven.capture_exception(e)
      errors.add(:base, e.message)
      context.fail!(errors: errors)
    end

  private

    def user_signed_in?
      KeycloakClient.instance.user_signed_in?(access_token)
    end

    def api_client
      KeycloakClient.instance
    end

    def refresh_token
      context.dig("omniauth_response", "credentials", "refresh_token")
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end
  end
end
