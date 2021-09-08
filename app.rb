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
  params.delete('splat')
  params_key = params.sort_by { |k, _| k }.map { |k, v| [k, v].join(':') }.join(':')
  query = params.sort_by { |k, _| k }.map { |k, v| "#{k}=#{v}" }.join('&')
  key = "#{Date.today.to_s}:#{path}:#{params_key}"
  settings.cache.fetch(key) do
    url = "https://api.propertydata.co.uk/#{path}?key=#{ENV['PROPERTY_TOKEN']}&#{query}"
    HTTP.get(url).body.to_s
  end
end
