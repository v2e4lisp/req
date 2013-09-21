require "./spec_helper"

describe "Post to localhost:4567" do
  url = base
  query = {"x" => 1}

  it "should success" do
    request(url).post.should respond_status(200)
  end

  describe "Post form" do
    it "should return the same query data" do
      request(url).query(query).post.body.from_json.should eq({"x" => "1"})
    end
  end

  describe "Post json" do
    it "should reutrn the same json data" do
      request(url).query(query).json.post.body.from_json.should eq(query)
    end
  end
end
