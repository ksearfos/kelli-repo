require 'spec_lib/TestRunner'
require 'spec_lib/RecordComparerRunner'
require 'rspec'
require 'rspec/expectations'
require 'rspec/mocks'

RSpec.configure do |c|
  c.fail_fast = true
  c.formatter = :documentation
end