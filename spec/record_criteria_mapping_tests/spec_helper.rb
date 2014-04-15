$LOAD_PATH.unshift(File.dirname(__FILE__).join("../../"))
puts $LOAD_PATH[0...2]
require 'test_classes'
require 'rspec'
require 'rspec/expectations'

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
