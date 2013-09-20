require "./spec_helper"

describe "Get from localhost:4567" do
  url = "http://localhost:4567"

  it "should success" do
    request(url).get.should respond_status(200)
  end

  it "should return the query string" do
    query = "x=1"
    request("#{url}?#{query}").get.body.should eq(query)
  end
end
