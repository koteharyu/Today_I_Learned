require "net/http"
require "uri"
require "json"
uri = URI("https://www.example.com")
result = Net::HTTP.post(uri, {mocha: 400}.to_json, "Content-Type" => "application/json")
p result