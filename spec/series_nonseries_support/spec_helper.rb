require 'lib/OHmodule/OhioHealthUtilities'
require 'lib/SeriesNonseriesSupport.rb'
require 'rspec'
require 'rspec/expectations'

file = HL7::FileHandler.new("#{File.dirname(__FILE__)}/test_data.txt")
$messages = {}
file.records.map do |record|
  $messages[record[:PID].patient_name] = record
end
$criteria = { obx_potassium:Proc.new { |rec| OhioHealthUtilities.is_val?(rec,"obx3","K+^Potassium") },
              obx_sodium:Proc.new { |rec| OhioHealthUtilities.is_val?(rec,"obx3","URNA^Sodium,UR") },
              obx_chloride:Proc.new { |rec| OhioHealthUtilities.is_val?(rec,"obx3","CL^Chloride") },
              obx_fake:Proc.new { |rec| OhioHealthUtilities.is_val?(rec,"obx3","FAKE^Fictitious Analyte") },
              male:Proc.new { |rec| OhioHealthUtilities.is_val?(rec, "pid8", "M") },
              female:Proc.new { |rec| OhioHealthUtilities.is_val?(rec, "pid8", "F") }
            }

RSpec.configure do |c|
  c.fail_fast = true
end

def should_pass_for_type(type, values, &block)
  response = block.call
  response.should == values[type]
end