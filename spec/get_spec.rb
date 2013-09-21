require "./spec_helper"

describe "Get from localhost:4567" do
  url = base
  it "should success" do
    request(url).get.should respond_status(200)
  end

  it "should return the query data" do
    query = "x=1"
    request("#{url}?#{query}").get.body.from_json.should eq({"x" => "1"})
  end

  describe "Using query or send to set query data" do
    it "Set data in one query" do
      request(url).send(hello: "x", world: 1).get.body.from_json
        .should eq({"hello" => "x", "world" => "1"})
    end

    it "Multiple query call will merge the data" do
      request(url).send(hello: "x").send(world: 1).get.body.from_json
        .should eq({"hello" => "x", "world" => "1"})
      request(url).query(hello: "x").query(world: 1).get.body.from_json
        .should eq({"hello" => "x", "world" => "1"})
    end
  end
end
