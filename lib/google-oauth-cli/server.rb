# frozen_string_literal: true

class GoogleOAuthCli
  class Server
    def initialize(port:, state:)
      @server = TCPServer.new port
      @state = state
    end

    def start
      loop do
        connection = server.accept
        request = connection.gets
        data = handle_request(request)
        connection.write <<~DOC
          HTTP/1.1 200 OK
          Content-Type: text/plain; charset=UTF-8

          OAuth request received. You can close this window now.
        DOC
        connection.close
        if data
          server.close
          return data
        end
      end
    end

    private

    attr_reader :server, :state

    def handle_request(request)
      _, full_path = request.split
      return if URI(full_path).path != "/authorize"

      params = CGI.parse(URI.parse(full_path).query)
      raise(Error, "Invalid oauth request received") if @state != params["state"][0]

      params["code"][0]
    end
  end
end
