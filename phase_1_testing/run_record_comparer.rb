#!/bin/env ruby

require "Record_Comparer/RecordComparer.rb"
require "Record_Comparer/OHProcs.rb"
require 'logger'

def run_record_comparer( csv_file, messages )
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
  matched = comparer.get_matched.unshift( "==========MATCHED==========" )
  unmatched = comparer.get_unmatched.unshift( "==========UNMATCHED==========" )

  # log completion in the logger
  $logger.info comparer.summary
  $logger.info "Criteria checked:\n#{[matched,unmatched].make_table}\n"  
  
  CSV.make_spreadsheet_from_array( csv_file, comparer.get_used )
  $logger.info "See #{csv_file}\n"
end