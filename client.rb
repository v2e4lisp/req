module Request

  TYPE = {json: 'application/json',
          form: 'application/x-www-form-urlencoded',
          text: 'text/plain',
          html: 'text/html',
          xml: 'application/xml'}

  class Client
    attr_accessor :data, :files, :body, :headers
    attr_reader :client, :url

    def initialize(url)
      self.url = url
      @data = {}
      @headers = {}
      @files = []
      @body = ''
      @client = Net::HTTP.new(uri.hostname, uri.port)
      use_ssl if uri.scheme == "https"
    end

    # http verbs
    [:get, :head, :delete, :options].each do |method|
      define_method method do
        update_uri
        client.send(method, uri.request_uri, headers)
      end
    end

    [:post, :put, :patch].each do |method|
      define_method method do
        build
        client.send(method, uri.request_uri, body, headers)
      end
    end

    def use_ssl use=true
      client.use_ssl = use
      self
    end

    # if not schema is given, default is `http`
    def url= url
      @url = (url['://'] ? '' : 'http://') << url
    end

    # basic authentication
    def auth user, pass
      set "Authorization" => "Basic #{Base64.encode64(user + ":" + pass).chop}"
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
      build_header
    end

    def build_header
      return if headers['Content-Length']
      headers['Content-Length'] = body.bytesize.to_s
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
end
