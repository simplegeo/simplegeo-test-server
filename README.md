# SimpleGeo Test Server

This is a mock SimpleGeo server that will reliably return the same responses
for repeatable requests.

## Getting Started

First, install dependencies using `gem`:

    $ sudo gem install oauth json sinatra

Or, if you're using [Bundler](http://gembundler.com/):

    $ bundle install

Start the mock SimpleGeo server:

    $ ruby -rubygems server.rb

If it worked, it should say something like:

    == Sinatra/1.1.0 has taken the stage on 4567 for development with backup from Mongrel

