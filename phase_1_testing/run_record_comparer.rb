#!/bin/env ruby

require "Record_Comparer/RecordComparer.rb"
require "Record_Comparer/OHProcs.rb"
require 'logger'

def run_record_comparer( results_file, messages )
  type = messages[0].type  
  fields = {}
  if type == :adt
    fields = { hospital_service:"pv110", admit_source:"pv114", patient_type:"pv118", financial_class:"pv120",
               discharge_disposition:"pv136" }   
  elsif type == :lab  
    fields = { procedure_id:"obr4", amalyte:"obx4" }
  else # type == :rad
    fields = { procedure_id:"pbr4" }  
  end

  # for each of those fields, we want to 
  # a. get all values appearing in the messages - done with HL7Test.get_data
  # b. define a new OHProcs constant storing each of those values - done with OHProcs.define_group
  # c. add it to the list of criteria to check - done with var.merge
  var = OHProcs.instance_variable_get( "@#{type}" )
  fields.each{ |id,field| var.merge! OHProcs.define_group(field, HL7Test.get_data(messages,field), id) }
  
  # make new record comparer
  comparer = RecordComparer.new( messages, type )
  comparer.analyze

  # the following goes into results_file
  File.open( results_file, "w" ) { |f|
    f.puts "==========MATCHED=========="
    f.puts comparer.matched
    f.puts ""
    f.puts "==========UNMATCHED=========="
    f.puts comparer.unmatched
    f.puts ""
  }

  # log completion in the logger
  $logger.info comparer.summary
  $logger.info "Record search completed."  
  comparer.used_records
end