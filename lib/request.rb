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
    def create url
      client = Client.new(url)
      if block_given?
        client.client.start { yield(client) }
      else
        client
      end
    end
    alias_method :new, :create
    alias_method :start, :create

    def [](url)
      Client.new(url)
    end
  end
end
