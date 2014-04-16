$LOAD_PATH.unshift File.expand_path("../../../", __FILE__)
require 'mixins/ProportionEvaluable'
require 'rspec'
require 'rspec/expectations'
require 'rspec/mocks'

RSpec.configure do |c|
  c.fail_fast = true
  c.formatter = :documentation
end