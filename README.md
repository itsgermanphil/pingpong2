
# What

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

# How

## Rounds

Ping pang (pingpong.herokuapp.com was taken) has two parallel tournamnets running at all times.

The first tournament is divided into Rounds, and each Round has up to 5 Tiers. All participanting players are divided amongst these tiers.

Players play everybody in their tier.  When everybody has played all their games, the round ends and the next round begins, but first:
- the two players who score the most points move up to the next tier and,
- the bottom two move down to a lower tier.

## 1-vs-1

The problem with the Rounds system is that some people want to play a lot more than others.

So, we bolted on an [Elo rating system](http://en.wikipedia.org/wiki/Elo_rating_system) and allows any two players to challenge each other to a 1-on-1 game.

You can see the results on http://pingpang.herokuapp.com/players which is sorted by (adjusted) Elo rating. Clicking into each player will show a history of their 1-on-1 games (which contribute to their Elo rating) and their "non-ranked" games played in the other Round structure.
