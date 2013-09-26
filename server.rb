require 'sinatra'
require "sinatra/multi_route"
require "sinatra/cookies"
require 'json'

def header_titleize header
  header.split("_").map {|w| w.capitalize }.join "-"
end

class Httpbin < Sinatra::Base
  register Sinatra::MultiRoute
  helpers Sinatra::Cookies
  include FileUtils::Verbose

  def authorized? user="test", pass="test"
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? &&
      @auth.basic? &&
      @auth.credentials &&
      @auth.credentials == [user, pass]
  end

  def echo
    request.env.inject({}) { |acc, item|
      acc.tap do |result|
        if item[0]["HTTP_"]
          result[header_titleize(item[0].gsub(/^HTTP_/, ""))] = item[1]
        end
      end
    }.tap {|header|
      header["Content-Type"] = env["CONTENT_TYPE"] if env["CONTENT_TYPE"]
    }.to_json
  end

  def data
    if request.env["CONTENT_TYPE"] == "application/json"
      request.body
    else
      params.to_json
    end
  end

  def render_cookies
    cookies.to_hash.to_json
  end

  before '/auth*' do
    path = params[:splat].first
    user, pass = path["/"] ? path[1..-1].split("/") : ["test", "test"]
    unless authorized? user, pass
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Oops... we need your login name & password\n"])
    end
  end

  get "/cookie" do
    render_cookies
  end

  get "/cookie/delete/:name" do
    #response.delete_cookie params[:name]
    response.set_cookie(params[:name],
                        value: "",
                        path: "/cookie",
                        :expires => Time.now - 3600*24)
    params[:name]
  end

  get "/cookie/:name/:value" do
    response.set_cookie(params[:name],
                        value: params[:value],
                        path: "/cookie")
    render_cookies
  end

  get "/upload" do
    <<-FORM
    <form action='/upload' enctype="multipart/form-data" method='post'>
    <input name="file" type="file" />
    <input name="var" type="text" />
    <input type="submit" value="Upload" />
</form>
FORM
  end

  route :post, :put, "/upload" do
    params[:file][:tempfile].read
    # request.body
  end

  route :get, :post, :put, :patch, :delete, "/auth" do
    data
  end

  route :get, :post, :put, :patch, :delete, "/auth/:user/:pass" do
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
