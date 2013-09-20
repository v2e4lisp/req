require 'sinatra'
# require 'query'
require 'json'

class Httpbin < Sinatra::Base
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? &&
      @auth.basic? &&
      @auth.credentials &&
      @auth.credentials == ["test","test"]
  end

  get "/auth" do
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Oops... we need your login name & password\n"])
    end
    "ok"
  end

  get '/' do
    request.query_string
  end

  post '/' do
    case request.env["Content-Type"]
    when "application/json" then JSON.parse(request.body.read)
    else request.body.read
    end
  end
end

Httpbin.run!
