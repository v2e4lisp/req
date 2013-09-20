require File.dirname(__FILE__) + '/query'
require 'net/http'
require 'json'
require 'base64'

module Request
  extend self

  MIME = {json: 'application/json',
    form: 'application/x-www-form-urlencoded'}

  class Client
    attr_accessor :data, :headers, :url
    attr_reader :client

    def initialize(url)
      @url = url
      @client = Net::HTTP.new(uri.hostname, uri.port)
      @data = {}
      @headers = {}
    end

    def uri
      @uri ||= url.is_a?(URI::HTTP) ? url : URI(url)
    end

    def auth user, pass
      set "Authorization" => "Basic #{Base64.encode64(user + ":" + pass).chop}"
    end

    def get
      unless data.empty?
        url << "?" unless url["?"]
        url << data.to_query
        @uri = nil
      end
      client.get uri.request_uri, headers
    end

    def post
      if headers['Content-Type'] == MIME[:json]
        client.post uri.request_uri, data.to_json, headers
      else
        client.post uri.request_uri, data.to_query, headers
      end
    end

    def query option
      @data.merge! option
      self
    end

    def set option
      @headers.merge! option
      self
    end
    alias_method :header, :set

    def json
      set('Content-Type' => MIME[:json])
    end

    def form
      set('Content-Type' => MIME[:form])
    end
  end
end

# API
def request url
  Request::Client.new(url)
end

# url = "http://localhost:4567"
# p request(url).get.body
# p JSON.parse(request(url).json.query("p" => 12).post.body)
# p JSON.parse(request(url).query("p" => 12).post.body)
