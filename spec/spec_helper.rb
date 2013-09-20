require '../http.rb'
require "json"

class String
  def from_json
    JSON.parse self
  end
end

RSpec.configure do |config|
end

RSpec::Matchers.define :respond_status do |code|
  match do |actual|
    actual.code.to_i == code.to_i
  end
end
