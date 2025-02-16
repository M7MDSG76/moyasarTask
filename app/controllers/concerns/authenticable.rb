module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  def authenticate_request
    token = request.headers["Authorization"]&.split("Bearer ")&.last
    api_token = ApiToken.find_by(token: token) # token manually gereated and saved in the DB.
    head :unauthorized unless api_token
  end
end
