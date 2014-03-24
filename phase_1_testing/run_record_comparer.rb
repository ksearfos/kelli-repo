#!/bin/env ruby

require 'lib/RecordComparer'
require 'lib/extended_base_classes'
require 'lib/HL7CSV'
require 'logger'

def run_record_comparer( file, messages, final )
  type = messages[0].type  
  
  add_dynamic_fields( messages, type ) 
  
  # make new record comparer
  comparer = RecordComparer.new( messages, type )
  comparer.analyze
  $logger.info "Finished running record comparer. #{comparer.recs_to_use.size} records required."   
  
  if final  
    fluff = '=' * 10
    matched = comparer.get_matched.unshift( "#{fluff} MATCHED #{fluff}" )
    unmatched = comparer.get_unmatched.unshift( "#{fluff} UNMATCHED #{fluff}" )

    # log completion in the logger
    $logger.info comparer.summary
    $logger.info "Criteria checked:\n#{[matched,unmatched].make_table}\n"  
    save_results( file, comparer.use )
  else
    $logger.info "Writing to #{file}...\n"
    f = File.open( file, "a+" )
    comparer.recs_to_use.each{ |r| f.puts r.to_s }
    f.close
  end
end

def add_dynamic_fields( messages, type )
  fields = OHProcs.const_get( "#{type.upcase}_FIELDS_TO_ADD" )  # criteria to add
  var = OHProcs.instance_variable_get( "@#{type}" )             # all criteria
  
  # add our new criteria to the list of all criteria
  # need to make new groups first, of course
  fields.each{ |id,field| var.merge! OHProcs.define_group(field, HL7Test.get_data(messages,field), id) }
end

def save_results( csv_file, recs )
  HL7CSV.records_to_spreadsheet( csv_file, recs )
  $logger.info "See #{csv_file}\n"
end
