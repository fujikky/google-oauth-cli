# google-oauth-cli

[![gem version](https://badge.fury.io/rb/google-oauth-cli.svg)](https://badge.fury.io/rb/google-oauth-cli)
![test](https://github.com/fujikky/google-oauth-cli/actions/workflows/test.yml/badge.svg?branch=main)

`google-oauth-cli` is a RubyGems library that allows you to perform OAuth authentication with Google from the CLI.

## Features

- Authenticate with Google using OAuth from the CLI.
- Start a simple web server to receive authentication codes.
- You can persist a refresh token by passing a file path as an optional argument. If a refresh token is present, the authentication flow is skipped and the access token refresh process is performed.

## Motivation

[Google deprecates to the OOB flow by Google in February 2022](https://developers.google.com/identity/protocols/oauth2/resources/oob-migration).

## Usage

```rb
auth = GoogleOAuthCli.new(
  client_id: ENV["client_id"],
  client_secret: ENV["client_secret"],
  scope: ["https://www.googleapis.com/auth/drive", "https://spreadsheets.google.com/feeds"],
  credentials_file: "~/.config/google-test.json"
)

# Starts authentication flow and returns Google::Auth::UserRefreshCredentials
credentials = auth.login

drive = Google::Apis::DriveV3::DriveService.new
drive.authorization = credentials
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

MIT
