# frozen_string_literal: true

require "googleauth"
require "launchy"
require_relative "google-oauth-cli/version"
require_relative "google-oauth-cli/server"

class GoogleOAuthCli
  class Error < StandardError; end

  def initialize(client_id:, client_secret:, scope:, credentials_file: nil, port: 9876)
    @credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: client_id,
      client_secret: client_secret,
      scope: scope,
      redirect_uri: "http://localhost:#{port}/authorize",
      additional_parameters: { access_type: "offline" }
    )
    if credentials_file
      @credentials_file = Pathname.new(File.expand_path(credentials_file))
      @credentials_file
    end
    @port = port
  end

  def login
    authorize_from_credentials || authorize_from_authorization_code_flow
  end

  private

  attr_reader :credentials, :credentials_file, :port

  def authorize_from_credentials
    return nil unless credentials_file&.exist?

    token = JSON.parse(credentials_file.read)["refresh_token"]
    return nil if token.nil?

    credentials.refresh_token = token
    fetch_and_save_token!

    credentials
  end

  def authorize_from_authorization_code_flow
    state = SecureRandom.base64(16)
    credentials.state = state

    uri = credentials.authorization_uri
    Launchy.open(uri) do |exception|
      raise(Error, "Attempted to open #{uri} and failed because #{exception}")
    end

    credentials.code = start_server_and_receive_code(state)
    fetch_and_save_token!

    credentials
  end

  def fetch_and_save_token!
    credentials.fetch_access_token!
    credentials_file&.write({ refresh_token: credentials.refresh_token }.to_json)
  end

  def start_server_and_receive_code(state)
    server = Thread.new do
      Thread.current.report_on_exception = false
      Server.new(port: port, state: state).start
    end
    server.join
    server.value
  end
end
