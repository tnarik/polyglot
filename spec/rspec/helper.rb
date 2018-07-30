require "rspec"
require 'rspec/mocks'
# require 'minitest/autorun'
require "jekyll/polyglotter"
require "jekyll"

Dir[File.expand_path("../../support/*.rb", __FILE__)].each do |v|
  require v
end

def fixtures_path
  File.expand_path('../../fixtures', __FILE__)
end

include Jekyll

