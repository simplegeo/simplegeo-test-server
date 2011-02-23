require 'json'
require 'sinatra'
require 'digest/sha1'
require File.dirname(__FILE__) + '/examples'
require File.dirname(__FILE__) + '/lib/rack_oauth_provider'

use RackOAuthProvider

get '/1.0/features/categories.json' do
  CATEGORIES
end

get '/1.0/features/:id.json' do
  case params[:id]
  when /^SG_4CsrE4oNy1gl8hCLdwu0F0/
    BURGER_MASTER
  when /^SG_0Bw22I6fWoxnZ4GDc8YlXd/
    CASTRO
  when /^SG_3tLT0I5cOUWIpoVOBeScOx/
    if params[:zoom] == "0"
      LOS_ANGELES
    else
      404
    end
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
    when "one", "öne"
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

get '/1.0/places/address.json' do
  if params[:address]
      <<-EOS
{
    "total": 0,
    "type": "FeatureCollection",
    "features": [#{MOUNTAIN_SUN}]
}
    EOS
  else
    500
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

  if params[:id] == 'SG_garbage'
    [404, {'Content-type' => 'application/json'}, "{\"message\": \"Not Found\", \"code\": 404}"]
  else
    [202, {'Content-Type' => 'application/json'}, '{"token": "8fa0d1c4fc2911dfa39058b035fcf1e5"}']
  end
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
    if input['properties']['city'] == "Gildford"
        500
    elsif input['properties']['private'] == "true"
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

# create / update a record
put '/0.1/records/:layer/:id.json' do
  input = JSON.parse(env['rack.input'].read)

  if input['type'] && input['geometry'] && input['properties']
    202
  else
    [400, {'Content-type' => 'application/json'}, "{\"message\": \"Couldn't decode JSON object.\", \"code\": 400}"]
  end
end

# get a record
get '/0.1/records/:layer/:id.json' do
  STORAGE_BOULDER
end

# delete a record
delete '/0.1/records/:layer/:id.json' do
  if params[:id] == "nonexistent"
    [404, {'Content-type' => 'application/json'}, "{\"message\": \"No such record.\", \"code\": 404}"]
  else
    [202, {'Content-Type' => 'application/json'}, '{"status": "deleted"}']
  end
end

# create / update multiple records
post '/0.1/records/:layer.json' do
  input = JSON.parse(env['rack.input'].read)

  if input['type'] == 'FeatureCollection'
    # TODO each record must contain an id field
    202
  else
    400
  end
end

# find nearby records
get '/0.1/records/:layer/nearby/:lat,:lon.json' do
  # TODO add sentinel values for different types of queries
  STORAGE_QUERY
end

# find records near an IP
get '/0.1/records/:layer/nearby/:ip.json' do
  # TODO return a sentinel value to distinguish this from point queries
  STORAGE_QUERY
end

# find records near an address
get '/0.1/records/:layer/nearby/address.json' do
  # TODO return a sentinel value to distinguish this from point queries
  STORAGE_QUERY
end

# get record history
get '/0.1/records/:layer/:id/history.json' do
  STORAGE_HISTORY
end
