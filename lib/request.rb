require 'net/http'
require 'json'
require 'base64'
require 'mime/types'
require "request/version"
require "request/query"
require "request/part"
require "request/client"

module Request
  class << self
    def [](url)
      Client.new(url)
    end
  end
end
