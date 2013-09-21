require "./spec_helper"
include Helpers

describe "basic auth" do
  describe "using auth method for basic authentication" do
    url = base + "/auth"
    it "should return ok" do
      req = request(url).auth("test", "test")
      request(url).auth("test", "test").get.body.should eq("{}")
    end

    it "should fail when no user or password" do
      request(url).get.should respond_status(401)
    end

    it "should fail when invalid user and password" do
      request(url).auth("fake", "test").get.should respond_status(401)
    end
  end

  describe "using url for basic authentication" do
    it "should return ok" do
      url = "http://test:test@localhost:4567/auth"
      request(url).get.body.should eq("{}")
    end

    it "should fail when invalid user and password" do
      url = "http://fake:test@localhost:4567/auth"
      request(url).get.should respond_status(401)
    end
  end
end
