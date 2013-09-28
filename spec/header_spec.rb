require "./spec_helper"
include Helpers

describe "Request.header" do
  url = base + "/headers"

  it "set multiple header" do
    request(url).header("X-1" => "x1").header("X-2" => "x2").get
    .should send_header("X-1" => "x1","X-2" => "x2")
  end

  describe "Content-Type" do
    describe "#header" do
      it "set to application/json" do
        request(url).header("Content-Type" => "xxx").post
        .should send_header("content-type" => "xxx")
      end
    end

    describe "#type" do
      it "set Content-Type to customized type" do
        request(url).type("xxx").post
        .should send_header("content-type" => "xxx")
      end

      it "set Content-Type to text/html" do
        request(url).type(:html).post
        .should send_header("content-type" => "text/html")
      end

      it "set Content-Type to application/json" do
        request(url).type(:json).post
        .should send_header("content-type" => "application/json")
      end

      it "set Content-Type to application/x-www-form-urlencoded" do
        request(url).type(:form).post
        .should send_header("content-type" =>
                            "application/x-www-form-urlencoded")
      end

      it "set Content-Type to application/xml" do
        request(url).type(:xml).post
        .should send_header("content-type" => "application/xml")
      end

      it "set Content-Type to text/plain" do
        request(url).type(:text).post
        .should send_header("content-type" => "text/plain")
      end
    end
  end
end
