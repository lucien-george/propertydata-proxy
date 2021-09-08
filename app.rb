require 'date'
require 'sinatra'
require 'redis-sinatra'
require 'http'

register Sinatra::Cache

get "/" do
  settings.cache.fetch('ping') { 'pong' }
end

get "/*" do
  content_type 'application/json'
  path = params[:splat].first
  key = "#{Date.today.to_s}:#{path}"
  settings.cache.fetch(key) do
    url = "https://api.themoviedb.org/3/#{path}?api_key=#{ENV['TMDB_API_KEY']}"
    HTTP.get(url).body.to_s
  end
end
