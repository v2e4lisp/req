require "./spec_helper"
include Helpers

describe "header" do
  url = base + "/headers"

  it "set multiple header" do
     request(url).header("X-1" => "x1").header("X-2" => "x2").get
    .should send_header("X-1" => "x1","X-2" => "x2")
  end

  describe "Content-Type" do
    it "set to application/json" do
      request(url).header("Content-Type" => "xxx").post
      .should send_header("content-type" => "xxx")
    end

    it "Using type to set Content-Type" do
      request(url).type("xxx").post
      .should send_header("content-type" => "xxx")
    end

    it "Using type shortcut to set Content-Type" do
      request(url).type(:html).post
      .should send_header("content-type" => "text/html")
    end

    it "Using json to set Content-Type to application/json" do
      request(url).json.post
      .should send_header("content-type" => "application/json")
    end

    it "Using form to set Content-Type to application/x-www-form-urlencoded" do
      request(url).form.post
      .should send_header("content-type" => "application/x-www-form-urlencoded")
    end
  end
end
