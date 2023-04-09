# frozen_string_literal: true

RSpec.describe GoogleOAuthCli do
  it "#login" do
    credentials_mock = double(Google::Auth::UserRefreshCredentials)
    allow(credentials_mock).to receive(:authorization_uri).and_return("http://example.com/")
    allow(credentials_mock).to receive(:state=)
    allow(credentials_mock).to receive(:code=)
    allow(credentials_mock).to receive(:fetch_access_token!)

    allow(Google::Auth::UserRefreshCredentials).to receive(:new).and_return(credentials_mock)
    allow(Launchy).to receive(:open)
    allow_any_instance_of(GoogleOAuthCli::Server).to receive(:start).and_return("some-code")

    auth = described_class.new(
      client_id: "client_id",
      client_secret: "client_secret",
      scope: "scope"
    )
    result = auth.login

    expect(Google::Auth::UserRefreshCredentials).to have_received(:new).with(
      client_id: "client_id",
      client_secret: "client_secret",
      scope: "scope",
      redirect_uri: "http://localhost:9876/authorize",
      additional_parameters: { access_type: "offline" }
    )
    expect(credentials_mock).to have_received(:state=).with(instance_of(String))
    expect(Launchy).to have_received(:open).with("http://example.com/")
    expect(credentials_mock).to have_received(:code=).with("some-code")
    expect(credentials_mock).to have_received(:fetch_access_token!)
    expect(result).to eq(credentials_mock)
  end
end
