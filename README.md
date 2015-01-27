# README

This is the 500px in-house app for tracking our on-going table tennis tournament.

To log in, you'll need a consumer key/secret to connect with 500px. See https://500px.com/settings/applications.

Set your consumer key/secret as environment variables.

You can do this easily by creating a file called `start.sh` in the root of your project:

    #!/bin/bash
    CONSUMER_KEY=XXX CONSUMER_SECRET=yyy ./rails server -p 3000
    
This is used by `config/initializers/omniauth.rb`:

    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :fiveHundredPx, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
    end

You'll also need PostgresSQL.
