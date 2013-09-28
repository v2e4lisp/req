require File.dirname(__FILE__) + '/query'
require 'net/http'
require 'json'
require 'base64'
require 'mime/types'

module Request
  TYPE = {json: 'application/json',
          form: 'application/x-www-form-urlencoded',
          text: 'text/plain',
          html: 'text/html',
          xml: 'application/xml'}

  class << self
    def [](url)
      client = Client.new(url)
      block_given? ? yield(client) : client
    end
    alias_method :create, :[]
  end

  class Client
    attr_accessor :data, :files, :body, :headers
    attr_reader :client, :url

    def initialize(url)
      @data = {}
      @headers = {}
      @files = []
      @body = ''
      self.url = url
      @client = Net::HTTP.new(uri.hostname, uri.port)
    end

    def use_ssl use=true
      client.use_ssl = use
      self
    end

    def url= url
      # if not schema is given, default is `http`
      @url = (url['://'] ? '' : 'http://') << url
    end

    def auth user, pass
      # setup basic auth header
      set "Authorization" => "Basic #{Base64.encode64(user + ":" + pass).chop}"
    end

    def get
      update_uri
      client.get uri.request_uri, headers
    end

    def post
      build
      client.post(uri.request_uri, body, headers)
    end

    def put
      build
      client.put(uri.request_uri, body, headers)
    end

    def delete
    end

    def head
    end

    def send name, file=nil, filename=nil
      if file
        upload name, file, filename
      else
        query name
      end
    end

    def upload field, file, filename = nil
      file = File.open(file)
      @files << [field, file, filename || file.path]
      self
    end
    alias_method :attach, :upload

    def query option
      data.merge! option
      self
    end

    def header option
      headers.merge! option
      self
    end
    alias_method :set, :header

    def write body
      @body << body
      self
    end

    def type t
      # Set `Content-Type` header
      tp = t.to_sym
      t = TYPE[tp] if TYPE[tp]
      set "Content-Type" => t
    end

    def multi
      @multi = true
      self
    end

    private

    def build
      if not files.empty? or @multi
        build_multipart
      else
        build_body
      end
    end

    def build_header
    end

    def build_body
      case headers['Content-Type']
      when nil, TYPE[:form] then write data.to_query
      when TYPE[:json] then write data.to_json
      end
    end

    def build_multipart
      m = Multipart.create(files, data)
      write m.body
      header m.header
    end

    def update_uri
      unless data.empty?
        url << "?" unless url["?"]
        url << data.to_query
        @uri = nil
      end
    end

    def uri
      @uri ||= URI(url).tap do |u|
        # If the url is something like this: http://user:password@localhost",
        # we setup the basic authorization header.
        auth(u.user, u.password) if u.user and u.password
      end
    end
  end

  module Multipart
    BOUNDARY = "--ruby-request--"
    DEFAULT_MIME = "application/octet-stream"

    def self.create files, data
      Fields.new(files, data)
    end

    class Fields
      def initialize files, data
        @files = files || []
        @params = data || []
      end

      def body
        @body ||= '' << @files.inject("") { |acc, file|
          acc << Attachment.new(*file).part
        } << @params.inject("") { |acc, param|
          acc << Param.new(*param).part
        } << "--#{BOUNDARY}--\r\n\r\n"
      end

      def header
        @header ||= {"Content-Length" => @body.bytesize.to_s,
                     "Content-Type"   => "multipart/form-data; boundary=#{BOUNDARY}"}
      end
    end

    class Attachment < Struct.new(:field, :file, :filename)
      def part
        return @part if @part
        type = ::MIME::Types.type_for(filename).first || DEFAULT_MIME
        @part = ''
        @part << "--#{BOUNDARY}\r\n"
        @part << "Content-Disposition: form-data; name=\"#{field}\"; filename=\"#{filename}\"\r\n"
        @part << "Content-Type: #{type}\r\n\r\n"
        @part << "#{file.read}\r\n"
      end
    end

    class Param < Struct.new(:field, :value)
      def part
        return @part if @part
        @part = ''
        @part << "--#{BOUNDARY}\r\n"
        @part << "Content-Disposition: form-data; name=\"#{field}\"\r\n"
        @part << "\r\n"
        @part << "#{value}\r\n"
      end
    end
  end
end

# url = "http://httpbin.org/headers"
# url = "http://localhost:4567/upload"
# p Request[url].send(x: 1).attach("file", "/tmp/upload.txt").put.body
# p Request.create(url).send(x: 1).attach("file", "/tmp/upload.txt").post.body
# p request(url).get.body
# p JSON.parse(request(url).json.query("p" => 12).get.body)
# url = "http://localhost:4567/headers"
# p JSON.parse(request(url).json.query("p" => 12).get.body)
# p JSON.parse(request(url).query("p" => 12).post.body)
