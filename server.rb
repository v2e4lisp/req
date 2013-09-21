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
      @auth.credentials == [params[:user] || "test",
                            params[:pass] || "test"]
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

  def data
    if request.env["CONTENT_TYPE"] == "application/json"
      request.body
    else
      params.to_json
    end
  end

  before '/auth' do
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Oops... we need your login name & password\n"])
    end
  end

  route :get, :post, :put, :patch, :delete, "/auth" do
    data
  end

  route :get, :post, :put, :patch, :delete, "/headers" do
    echo
  end

  route :get, :post, :put, :patch, :delete, "/" do
    data
  end
end

Httpbin.run!
