require "./spec_helper"

describe "schema" do
  describe "without a schema defualt is http" do
    it "should be ok" do
      request("localhost:4567").get.should respond_status(200)
    end
  end

  describe "https and ssl" do
    # todo
  end
end
