require 'sinatra'
require "sinatra/multi_route"
require 'json'

def header_titleize header
  header.split("_").map {|w| w.capitalize }.join "-"
end

class Httpbin < Sinatra::Base
  register Sinatra::MultiRoute
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? &&
      @auth.basic? &&
      @auth.credentials &&
      @auth.credentials == ["test","test"]
  end

  def echo
    request.env.inject({}) { |acc, item|
      if item[0]["HTTP_"]
        acc[header_titleize(item[0].gsub(/^HTTP_/, ""))] = item[1]
      end
      acc
    }.tap {|header|
      if request.env["CONTENT_TYPE"]
        header["Content-Type"] = request.env["CONTENT_TYPE"]
      end
    }.to_json
  end

  get "/auth" do
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Oops... we need your login name & password\n"])
    end
    "ok"
  end

  route :get, :post, "/echo" do
    echo
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
