require "./spec_helper"

describe "Post to localhost:4567" do
  url = "http://localhost:4567/auth"

  it "should fail when no user or password" do
    request(url).get.should respond_status(401)
  end

  it "should fail when invalid user and password" do
    request(url).auth("fake", "test").get.should respond_status(401)
  end

  it "should return ok" do
    req = request(url).auth("test", "test")
    p req.headers
    request(url).auth("test", "test").get.body.should eq("ok")
  end
end
