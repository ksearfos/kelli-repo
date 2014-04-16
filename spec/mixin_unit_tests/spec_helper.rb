$LOAD_PATH.unshift File.expand_path("../../../", __FILE__)
require 'mixins/ProportionEvaluable'
require 'rspec'
require 'rspec/expectations'
require 'rspec/mocks'

RSpec.configure do |c|
  c.fail_fast = true
  c.formatter = :documentation
end

class ProportionEvaluable::ProportionEvaluator
  attr_reader :proportion, :all_elements, :qualifying_elements, :nonqualifying_elements
end

def new_size(old_amount, added_amount)
  old_amount + added_amount
end
