$LOAD_PATH.unshift File.expand_path("../../../", __FILE__)
require 'classes/RecordCriteriaMap'
require 'classes/ListOfMaps'
require 'rspec'
require 'rspec/expectations'
require 'rspec/mocks'

RSpec.configure do |c|
  c.fail_fast = true
  c.formatter = :documentation
end

$criteria = [:thing1, :thing2, :thing3]
$duplicate_criteria = [:thing1, :thing2, :thing3]
$redundant_criteria = [:thing1, :thing4]
$additional_criteria = [:thing4, :thing5]
$all_criteria = [:thing1, :thing2, :thing3, :thing4, :thing5]
$criteria_with_procs = { thing1: proc { true }, thing2: proc { true }, thing3: proc { true },
                         thing4: proc { false }, thing5: proc { false }
                       }
