require "net/http"
require "uri"
uri = URI.parse("https://igarashikuniaki.net/example.json")
p result = Net::HTTP.get(uri)