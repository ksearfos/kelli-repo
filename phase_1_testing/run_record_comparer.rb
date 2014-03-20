#!/bin/env ruby

require "Record_Comparer/RecordComparer.rb"
require "Record_Comparer/OHProcs.rb"
require 'logger'

def run_record_comparer( results_file, messages )
  type = messages[0].type  
  fields = OHProcs.const_get( "#{type.upcase}_FIELDS_TO_ADD" )

  # for each of those fields, we want to 
  # a. get all values appearing in the messages - done with HL7Test.get_data, and
  # b. add it to the list of criteria to check - done with var.merge
  var = OHProcs.instance_variable_get( "@#{type}" )
  fields.each{ |id,field| var.merge! OHProcs.define_group(field, HL7Test.get_data(messages,field), id) }
  
  # make new record comparer
  comparer = RecordComparer.new( messages, type )
  comparer.analyze

  # the following goes into results_file
  File.open( results_file, "w" ) { |f|
    f.puts "==========MATCHED=========="
    f.puts comparer.get_matched
    f.puts ""
    f.puts "==========UNMATCHED=========="
    f.puts comparer.get_unmatched
    f.puts ""
  }

  # log completion in the logger
  $logger.info comparer.summary
  $logger.info "Record search completed."  
  comparer.get_used
end