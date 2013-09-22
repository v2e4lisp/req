require File.dirname(__FILE__) + '/query'
require 'net/http'
require 'json'
require 'base64'

module Request
  extend self

  MIME = {json: 'application/json',
          form: 'application/x-www-form-urlencoded',
          html: 'text/html'}

  def self.create url
    Client.new(url)
  end

  class Client
    attr_accessor :data, :headers
    attr_reader :client, :url

    def initialize(url)
      @data = {}
      @headers = {}
      self.url = url
      @client = Net::HTTP.new(uri.hostname, uri.port)
    end

    def url= url
      # if not schema is given, default is `http`
      @url = (url['://'] ? '' : 'http://') << url
    end

    def uri
      @uri ||= URI(url).tap do |u|
        # If the url is something like this: http://user:password@localhost",
        # we setup the basic authorization header.
        auth(u.user, u.password) if u.user and u.password
      end
    end

    def auth user, pass
      # setup basic auth header
      set "Authorization" => "Basic #{Base64.encode64(user + ":" + pass).chop}"
    end

    def get
      # Reformat the url based on the query,
      # then send a get request.
      unless data.empty?
        url << "?" unless url["?"]
        url << data.to_query
        @uri = nil
      end
      client.get uri.request_uri, headers
    end

    def post
      # According the `Content-Type` header,
      # convert the hash data to url query string or json.
      if headers['Content-Type'] == MIME[:json]
        client.post uri.request_uri, data.to_json, headers
      else
        client.post uri.request_uri, data.to_query, headers
      end
    end

    def query option
      data.merge! option
      self
    end
    alias_method :send, :query

    def set option
      headers.merge! option
      self
    end
    alias_method :header, :set

    def attach file
    end

    def type t
      # Set `Content-Type` header
      tp = t.to_sym
      t = MIME[tp] if MIME[tp]
      set "Content-Type" => t
    end

    def json
      # Set Content-Type = application/json
      type MIME[:json]
    end

    def form
      # Set Content-Type = application/x-www-form-urlencoded
      type MIME[:form]
    end
  end
end

# API
def request url
  Request::Client.new(url)
end

# url = "http://httpbin.org/headers"
# p request(url).get.body
# p JSON.parse(request(url).json.query("p" => 12).get.body)
# url = "http://localhost:4567/headers"
# p JSON.parse(request(url).json.query("p" => 12).get.body)
# p JSON.parse(request(url).query("p" => 12).post.body)
