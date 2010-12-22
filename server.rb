require 'json'
require 'sinatra'
require 'digest/sha1'
require File.dirname(__FILE__) + '/examples'
require File.dirname(__FILE__) + '/lib/rack_oauth_provider'

use RackOAuthProvider

get '/1.0/features/:id.json' do
  case params[:id]
  when /^SG_4CsrE4oNy1gl8hCLdwu0F0/
    BURGER_MASTER
  when /^SG_0Bw22I6fWoxnZ4GDc8YlXd/
    CASTRO
  else
    404
  end
end

get '/1.0/places/:lat,:lon.json' do
  if params[:radius]
      <<-EOS
{
    "total": 0,
    "type": "FeatureCollection",
    "features": [#{MOUNTAIN_SUN}]
}
    EOS
  else
    case params[:q]
    when "zero"
      <<-EOS
{
    "total": 0,
    "type": "FeatureCollection",
    "features": []
}
      EOS
    when "one"
      <<-EOS
{
    "total": 1,
    "type": "FeatureCollection",
    "features": [
#{BURGER_MASTER}
    ]
}
      EOS
    else
      BURGERS
    end
  end
end

post '/1.0/features/:id.json' do
  # Update a record
  # Requires a partial (or full) GeoJSON object, any fields you set in it
  # replace the fields of the record with the matching ID.
  # Returns a status polling token

  input = JSON.parse(env['rack.input'].read)

  if env['CONTENT_TYPE'] == 'application/json' && input['properties']
    if input['properties']['private'] == "true"
      [202, {'Content-Type' => 'application/json'}, '{"token": "3489de320e1911e0b72e58b035fcf1e5"}']
    else
      [202, {'Content-Type' => 'application/json'}, '{"token": "79ea18ccfc2911dfa39058b035fcf1e5"}']
    end
  else
    500
  end
end

delete '/1.0/features/:id.json' do
  # Delete a record.
  # Requires a single SimpleGeo ID
  # Returns a status polling token

  [202, {'Content-Type' => 'application/json'}, '{"token": "8fa0d1c4fc2911dfa39058b035fcf1e5"}']
end

post '/1.0/places' do
  # Create a new record, returns a 202.
  # Requires a GeoJSON object
  # Returns a JSON blob : {'id': 'record_id', 'uri': 'uri_of_record', 'token':
  # 'status_polling_token'}

  input = JSON.parse(env['rack.input'].read)
  coordinates = input['geometry']['coordinates']

  hash = Digest::SHA1.hexdigest("com.simplegeo#{input['id']}")
  handle = "SG_#{hash}_#{coordinates[1]}_#{coordinates[0]}@#{Time.now.to_i}"

  if env['CONTENT_TYPE'] == 'application/json' && input['properties']
    if input['properties']['private'] == "true"
      [202, {'Content-Type' => 'application/json'},
       "{\"token\": \"0ff119100e1811e0b72e58b035fcf1e5\", \"id\": \"#{handle}\", \"uri\": \"/1.0/features/#{handle}.json\"}"]
    else
      [202, {'Content-Type' => 'application/json'},
       "{\"token\": \"596499b4fc2a11dfa39058b035fcf1e5\", \"id\": \"#{handle}\", \"uri\": \"/1.0/features/#{handle}.json\"}"]
    end
  else
    500
  end
end

get '/1.0/context/address.json' do
  if params[:address]
    <<-EOS
{
  "query": {
    "latitude": 40.01753,
    "longitude": -105.27741
  },
  #{CONTEXT_DEMOGRAPHICS},
  #{CONTEXT_FEATURES},
  #{CONTEXT_WEATHER}
}
    EOS
  else
    500
  end
end

get '/1.0/context/ip.json' do
  <<-EOS
{
  "query": {
    "latitude": 37.778381,
    "longitude": -122.389388
  },
  #{CONTEXT_DEMOGRAPHICS},
  #{CONTEXT_FEATURES},
  #{CONTEXT_WEATHER}
}
  EOS
end

get '/1.0/context/:lat,:lon.json' do
  # sample response for /1.0/context/37.803259,-122.440033.json
  <<-EOS
{
  "query": {
    "latitude": 37.803259,
    "longitude": -122.440033
  },
  #{CONTEXT_DEMOGRAPHICS},
  #{CONTEXT_FEATURES},
  #{CONTEXT_WEATHER}
}
  EOS
end

get '/1.0/context/:ip.json' do
  <<-EOS
{
  "query": {
    "latitude": 42.39020,
    "longitude": -71.11470
  },
  #{CONTEXT_DEMOGRAPHICS},
  #{CONTEXT_FEATURES},
  #{CONTEXT_WEATHER}
}
  EOS
end
