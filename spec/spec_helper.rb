require '../http.rb'
require "json"

class String
  def from_json
    JSON.parse self
  end
end

def base
  "http://localhost:4567"
end

# API
def request url
  Request::Client.new(url)
end

RSpec.configure do |config|
end

module Helpers
  extend RSpec::Matchers::DSL
  matcher :respond_status do |code|
    match do |actual|
      actual.code.to_i == code.to_i
    end
  end

  matcher :send_header do |header|
    match do |actual|
      actual_header = actual.body.from_json
      header.inject(true) do |acc, item|
        key = item.first.split("-").map {|w| w.capitalize }.join "-"
        acc and (actual_header[key] == item.last)
      end
    end
  end
end
