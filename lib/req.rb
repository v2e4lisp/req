require 'net/http'
require 'json'
require 'base64'
require 'mime/types'
require "req/version"
require "req/query"
require "req/part"
require "req/client"

module Req
  class << self
    def [](url)
      Client.new(url)
    end
  end
end
