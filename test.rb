#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/extended_base_classes'
require 'run_record_comparer'
require 'lib/hl7/HL7'
require 'lib/OHmodule/OHProcs'

INFILE = "C:/Users/Owner/Documents/script_input/rad_pre.txt"

handler = HL7::FileHandler.new( INFILE )
records = handler.records
criteria = { organization:"msh3" }
puts OHProcs.instance_variable_get( "@rad" )
HL7.get_data( records, "msh3" ).each{ |d| puts "'#{d}'"}
OHProcs.add_criteria_to_list( records, criteria, :rad )
puts OHProcs.instance_variable_get( "@rad" ).collect{ |name,proc| name if name.to_s.include? "organization" }

=begin
handler = HL7::FileHandler.new( INFILE, 15000 )
records = handler.records
count_series = Proc.new{ |recs|
  count = 0
  recs.each{ |r| count += 1 if OHProcs::SERIES_ENC.call(r) }
  count
}

puts "File contains #{count_series.call(records)} series encounters out of #{records.size} total encounters"
after = LIMIT_SERIES_ENCOUNTERS.call(records)
puts "After limiting, we have #{count_series.call(after)} series encounters out of #{after.size} total encounters"
=end