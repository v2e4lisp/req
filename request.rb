require File.dirname(__FILE__) + '/query'
require File.dirname(__FILE__) + '/part'
require File.dirname(__FILE__) + '/client'
require 'net/http'
require 'json'
require 'base64'
require 'mime/types'

module Request
  class << self
    def create url
      client = Client.new(url)
      block_given? ? yield(client) : client
    end
    alias_method :new, :create

    def [](url)
      Client.new(url)
    end
  end
end
